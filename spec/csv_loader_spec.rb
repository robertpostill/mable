# frozen_string_literal: true

require_relative 'spec_helper'
require 'tempfile'

RSpec.describe CsvLoader do
  describe '.load_accounts' do
    let(:csv_content) do
      <<~CSV
        1111234522226789,5000.00
        1111234522221234,10000.00
        2222123433331212,550.00
      CSV
    end

    let(:file) do
      t = Tempfile.new(['accounts', '.csv'])
      t.write(csv_content)
      t.flush
      t
    end

    after { file.close! }

    it 'returns one Account per row' do
      accounts = described_class.load_accounts(file.path)
      expect(accounts.size).to eq(3)
    end

    it 'parses account numbers correctly' do
      accounts = described_class.load_accounts(file.path)
      expect(accounts.map(&:number)).to eq(%w[1111234522226789 1111234522221234 2222123433331212])
    end

    it 'parses balances as BigDecimals' do
      accounts = described_class.load_accounts(file.path)
      expect(accounts.first.balance).to eq(BigDecimal('5000.00'))
    end

    it 'raises an error when the file does not exist' do
      expect { described_class.load_accounts('/nonexistent/path.csv') }
        .to raise_error(RuntimeError, /File not found/)
    end
  end

  describe '.load_transfers' do
    let(:csv_content) do
      <<~CSV
        1111234522226789,1212343433335665,500.00
        3212343433335755,2222123433331212,1000.00
      CSV
    end

    let(:file) do
      t = Tempfile.new(['transfers', '.csv'])
      t.write(csv_content)
      t.flush
      t
    end

    after { file.close! }

    it 'returns one Transfer per row' do
      transfers = described_class.load_transfers(file.path)
      expect(transfers.size).to eq(2)
    end

    it 'parses the from account number' do
      transfer = described_class.load_transfers(file.path).first
      expect(transfer.from_account_number).to eq('1111234522226789')
    end

    it 'parses the to account number' do
      transfer = described_class.load_transfers(file.path).first
      expect(transfer.to_account_number).to eq('1212343433335665')
    end

    it 'parses the amount as a BigDecimal' do
      transfer = described_class.load_transfers(file.path).first
      expect(transfer.amount).to eq(BigDecimal('500.00'))
    end
  end
end
