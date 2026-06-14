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

    let(:accounts) do
      result = []
      described_class.load_accounts(file.path) { |batch| result.concat(batch) }
      result
    end

    after { file.close! }

    it 'returns one Account per row' do
      expect(accounts.size).to eq(3)
    end

    it 'parses account numbers correctly' do
      expect(accounts.map(&:number)).to eq(%w[1111234522226789 1111234522221234 2222123433331212])
    end

    it 'parses balances as Money objects' do
      expect(accounts.first.balance).to eq(Money.from_amount(5000))
    end

    it 'raises an error when the file does not exist' do
      expect { described_class.load_accounts('/nonexistent/path.csv') {} } # rubocop:disable Lint/EmptyBlock
        .to raise_error(RuntimeError, /File not found/)
    end

    context 'when the file exceeds the batch size' do
      let(:csv_content) do
        (1..51).map { |i| "#{i.to_s.rjust(16, '0')},#{i}.00" }.join("\n")
      end

      it 'yields two batches' do
        batches = []
        described_class.load_accounts(file.path) { |batch| batches << batch }
        expect(batches.size).to eq(2)
      end

      it 'puts 50 accounts in the first batch' do
        first_batch = nil
        described_class.load_accounts(file.path) { |batch| first_batch ||= batch }
        expect(first_batch.size).to eq(50)
      end
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

    let(:transfers) do
      result = []
      described_class.load_transfers(file.path) { |batch| result.concat(batch) }
      result
    end

    after { file.close! }

    it 'returns one Transfer per row' do
      expect(transfers.size).to eq(2)
    end

    it 'parses the from account number' do
      expect(transfers.first.from_account_number).to eq('1111234522226789')
    end

    it 'parses the to account number' do
      expect(transfers.first.to_account_number).to eq('1212343433335665')
    end

    it 'parses the amount as a Money object' do
      expect(transfers.first.amount).to eq(Money.from_amount(500))
    end
  end
end
