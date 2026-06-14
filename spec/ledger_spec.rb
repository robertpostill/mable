# frozen_string_literal: true

require_relative 'spec_helper'

RSpec.describe Ledger do
  subject(:ledger) { described_class.new }

  let(:sender)    { Account.new('1111234522226789', '5000.00') }
  let(:recipient) { Account.new('1212343433335665', '1200.00') }
  let(:transfer)  { Transfer.new(sender.number, recipient.number, BigDecimal('500.00')) }

  before do
    ledger.add_account(sender)
    ledger.add_account(recipient)
  end

  describe '#add_account / #find_account' do
    it 'stores and retrieves an account by its number' do
      expect(ledger.find_account(sender.number)).to eq(sender)
    end

    it 'raises UnknownAccountError for an account that has not been added' do
      expect { ledger.find_account('9999999999999999') }
        .to raise_error(UnknownAccountError)
    end
  end

  describe '#process_transfer' do
    context 'when the transfer is valid' do
      it 'returns a successful TransferResult' do
        result = ledger.process_transfer(transfer)
        expect(result).to be_success
      end

      it "debits the sender's account" do
        ledger.process_transfer(transfer)
        expect(sender.balance).to eq(BigDecimal('4500.00'))
      end

      it "credits the recipient's account" do
        ledger.process_transfer(transfer)
        expect(recipient.balance).to eq(BigDecimal('1700.00'))
      end
    end

    context 'when the sender has insufficient funds' do
      let(:transfer) { Transfer.new(sender.number, recipient.number, BigDecimal('9999.00')) }

      it 'returns a failed TransferResult' do
        result = ledger.process_transfer(transfer)
        expect(result).to be_failure
      end

      it 'includes an informative error message' do
        result = ledger.process_transfer(transfer)
        expect(result.error_message).to include('insufficient funds')
      end

      it 'leaves the sender balance unchanged' do
        ledger.process_transfer(transfer)
        expect(sender.balance).to eq(BigDecimal('5000.00'))
      end

      it 'leaves the recipient balance unchanged' do
        ledger.process_transfer(transfer)
        expect(recipient.balance).to eq(BigDecimal('1200.00'))
      end
    end

    context 'when the sender account is unknown' do
      let(:transfer) { Transfer.new('0000000000000000', recipient.number, BigDecimal('10.00')) }

      it 'returns a failed TransferResult' do
        result = ledger.process_transfer(transfer)
        expect(result).to be_failure
      end

      it 'includes the unknown account number in the error message' do
        result = ledger.process_transfer(transfer)
        expect(result.error_message).to include('0000000000000000')
      end
    end

    context 'when the recipient account is unknown' do
      let(:transfer) { Transfer.new(sender.number, '0000000000000000', BigDecimal('10.00')) }

      it 'returns a failed TransferResult' do
        result = ledger.process_transfer(transfer)
        expect(result).to be_failure
      end
    end

    context 'when the transfer amount is not positive' do
      let(:transfer) { Transfer.new(sender.number, recipient.number, BigDecimal('0')) }

      it 'returns a failed TransferResult' do
        result = ledger.process_transfer(transfer)
        expect(result).to be_failure
      end
    end
  end

  describe '#process_transfers' do
    let(:transfers) do
      [
        Transfer.new(sender.number, recipient.number, BigDecimal('500.00')),
        Transfer.new(sender.number, recipient.number, BigDecimal('200.00'))
      ]
    end

    it 'returns a result for every transfer' do
      results = ledger.process_transfers(transfers)
      expect(results.size).to eq(2)
    end

    it 'debits the sender cumulatively across successful transfers' do
      ledger.process_transfers(transfers)
      expect(sender.balance).to eq(BigDecimal('4300.00'))
    end

    it 'credits the recipient cumulatively across successful transfers' do
      ledger.process_transfers(transfers)
      expect(recipient.balance).to eq(BigDecimal('1900.00'))
    end

    context 'when one transfer in the batch fails' do
      let(:results) do
        over_limit = Transfer.new(sender.number, recipient.number, BigDecimal('99999.00'))
        valid = Transfer.new(sender.number, recipient.number, BigDecimal('100.00'))
        ledger.process_transfers([over_limit, valid])
      end

      it 'marks the over-limit transfer as failed' do
        expect(results[0]).to be_failure
      end

      it 'continues to process the following transfer' do
        expect(results[1]).to be_success
      end
    end
  end
end
