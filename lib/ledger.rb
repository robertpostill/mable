# frozen_string_literal: true

# Holds all accounts for a company and processes batches of transfers.
class Ledger
  attr_reader :accounts

  def initialize
    @accounts = {}
  end

  def add_account(account)
    @accounts[account.number] = account
  end

  def find_account(number)
    @accounts[number.to_s] || raise(UnknownAccountError, number)
  end

  def process_transfer(transfer)
    from = find_account(transfer.from_account_number)
    to   = find_account(transfer.to_account_number)
    amount = BigDecimal(transfer.amount.to_s)

    raise InvalidTransferError, 'Transfer amount must be positive' unless amount.positive?

    from.debit(amount)
    to.credit(amount)

    TransferResult.new(transfer, true, nil)
  rescue InsufficientFundsError, UnknownAccountError, InvalidTransferError => e
    TransferResult.new(transfer, false, e.message)
  end

  def process_transfers(transfers)
    transfers.map { |t| process_transfer(t) }
  end
end
