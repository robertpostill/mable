# frozen_string_literal: true

require_relative 'spec_helper'
require 'tempfile'
require 'stringio'
require 'money'

RSpec.describe BankingService do
  subject(:service) { described_class.new }

  let(:balances_csv) do
    t = Tempfile.new(['balances', '.csv'])
    t.write(<<~CSV)
      1111234522226789,5000.00
      1111234522221234,10000.00
      2222123433331212,550.00
      1212343433335665,1200.00
      3212343433335755,50000.00
    CSV
    t.flush
    t
  end

  after { balances_csv.close! }

  describe '#load_accounts' do
    it 'populates the ledger with all accounts from the CSV' do
      service.load_accounts(balances_csv.path)
      expect(service.ledger.accounts.size).to eq(5)
    end
  end

  describe '#process_transfers' do
    let(:transfers_csv) do
      t = Tempfile.new(['transfers', '.csv'])
      t.write(<<~CSV)
        1111234522226789,1212343433335665,500.00
        3212343433335755,2222123433331212,1000.00
        3212343433335755,1111234522226789,320.50
        1111234522221234,1212343433335665,25.60
      CSV
      t.flush
      t
    end

    after { transfers_csv.close! }
    before { service.load_accounts(balances_csv.path) }

    it 'returns a result for every transfer in the file' do
      results = service.process_transfers(transfers_csv.path)
      expect(results.size).to eq(4)
    end

    it 'processes all four example transfers successfully' do
      results = service.process_transfers(transfers_csv.path)
      expect(results).to all(be_success)
    end

    it 'produces the expected final balance for account 1111234522226789' do
      # Starts at 5000.00, sends 500.00, receives 320.50 → 4820.50
      service.process_transfers(transfers_csv.path)
      balance = service.ledger.find_account('1111234522226789').balance
      expect(balance).to eq(Money.from_amount('4820.50'.to_r))
    end

    it 'produces the expected final balance for account 3212343433335755' do
      # Starts at 50000.00, sends 1000.00 and 320.50 → 48679.50
      service.process_transfers(transfers_csv.path)
      balance = service.ledger.find_account('3212343433335755').balance
      expect(balance).to eq(Money.from_amount('48679.50'.to_r))
    end

    it 'produces the expected final balance for account 1212343433335665' do
      # Starts at 1200.00, receives 500.00 and 25.60 → 1725.60
      service.process_transfers(transfers_csv.path)
      balance = service.ledger.find_account('1212343433335665').balance
      expect(balance).to eq(Money.from_amount('1725.60'.to_r))
    end
  end

  describe '#run' do
    let(:transfers_csv) do
      t = Tempfile.new(['transfers', '.csv'])
      t.write(<<~CSV)
        1111234522226789,1212343433335665,500.00
        3212343433335755,2222123433331212,1000.00
        3212343433335755,1111234522226789,320.50
        1111234522221234,1212343433335665,25.60
      CSV
      t.flush
      t
    end
    let(:output) { StringIO.new }
    let(:logger) do
      Logger.new(output).tap do |log|
        log.formatter = proc { |_severity, _datetime, _progname, msg| "#{msg}\n" }
      end
    end
    let(:service_with_logger) { described_class.new(logger: logger) }

    after { transfers_csv.close! }

    it 'outputs a summary without raising any errors' do
      expect do
        service_with_logger.run(balances_file: balances_csv.path, transfers_file: transfers_csv.path)
      end.not_to raise_error
    end

    it 'reports all transfers as succeeded in the sample data' do
      service_with_logger.run(
        balances_file: balances_csv.path,
        transfers_file: transfers_csv.path
      )
      expect(output.string).to include('4 succeeded, 0 failed')
    end
  end

  describe 'handling a transfer that would overdraw an account' do
    let(:overdraft_transfers_csv) do
      t = Tempfile.new(['overdraft', '.csv'])
      t.write("1111234522226789,1212343433335665,99999.00\n")
      t.flush
      t
    end

    after { overdraft_transfers_csv.close! }

    before { service.load_accounts(balances_csv.path) }

    it 'marks the transfer as failed' do
      results = service.process_transfers(overdraft_transfers_csv.path)
      expect(results.first).to be_failure
    end

    it 'does not change the sender balance' do
      service.process_transfers(overdraft_transfers_csv.path)
      expect(service.ledger.find_account('1111234522226789').balance).to eq(Money.from_amount(5000))
    end

    it 'does not change the recipient balance' do
      service.process_transfers(overdraft_transfers_csv.path)
      expect(service.ledger.find_account('1212343433335665').balance).to eq(Money.from_amount(1200))
    end
  end
end
