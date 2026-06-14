# frozen_string_literal: true

# rubocop:disable Style/OneClassPerFile

# Raised when a debit would exceed an account's available balance.
class InsufficientFundsError < StandardError
  def initialize(account, amount)
    super(
      "Account #{account.number} has insufficient funds " \
      "(balance: #{account.formatted_balance}, " \
      "requested: #{format('$%.2f', amount.to_d)})"
    )
  end
end

# Raised when an operation references an account number not in the ledger.
class UnknownAccountError < StandardError
  def initialize(account_number)
    super("Unknown account: #{account_number}")
  end
end

# Raised for structurally invalid transfers, e.g. non-positive amounts.
class InvalidTransferError < StandardError; end

# rubocop:enable Style/OneClassPerFile
