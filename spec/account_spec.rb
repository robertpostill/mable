# frozen_string_literal: true

require_relative 'spec_helper'

RSpec.describe Account do
  subject(:account) { described_class.new('1111234522226789', '5000.00') }

  describe '#initialize' do
    it 'stores the account number as a string' do
      expect(account.number).to eq('1111234522226789')
    end

    it 'stores the balance as a BigDecimal for precision' do
      expect(account.balance).to be_a(BigDecimal)
      expect(account.balance).to eq(BigDecimal('5000.00'))
    end
  end

  describe '#debit' do
    it 'reduces the balance by the given amount' do
      account.debit(BigDecimal('500.00'))
      expect(account.balance).to eq(BigDecimal('4500.00'))
    end

    it 'allows debiting the full balance (draining to zero)' do
      account.debit(BigDecimal('5000.00'))
      expect(account.balance).to eq(BigDecimal('0'))
    end

    it 'raises InsufficientFundsError when the amount exceeds the balance' do
      expect { account.debit(BigDecimal('5000.01')) }
        .to raise_error(InsufficientFundsError)
    end

    it 'does not modify the balance when the debit is rejected' do
      begin
        account.debit(BigDecimal('5000.01'))
      rescue StandardError
        nil
      end
      expect(account.balance).to eq(BigDecimal('5000.00'))
    end
  end

  describe '#credit' do
    it 'increases the balance by the given amount' do
      account.credit(BigDecimal('250.00'))
      expect(account.balance).to eq(BigDecimal('5250.00'))
    end
  end

  describe '#sufficient_funds?' do
    it 'returns true when balance covers the amount exactly' do
      expect(account.sufficient_funds?(BigDecimal('5000.00'))).to be true
    end

    it 'returns true when balance exceeds the amount' do
      expect(account.sufficient_funds?(BigDecimal('1.00'))).to be true
    end

    it 'returns false when balance is less than the amount' do
      expect(account.sufficient_funds?(BigDecimal('5000.01'))).to be false
    end
  end

  describe '#formatted_balance' do
    it 'formats the balance as a dollar string with two decimal places' do
      expect(account.formatted_balance).to eq('$5000.00')
    end
  end
end
