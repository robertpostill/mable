class InsufficientFundsError < StandardError
  def initialize(account, amount)
    super(
      "Account #{account.number} has insufficient funds " \
      "(balance: #{account.formatted_balance}, " \
      "requested: #{format('$%.2f', amount)})"
    )
  end
end

class UnknownAccountError < StandardError
  def initialize(account_number)
    super("Unknown account: #{account_number}")
  end
end

class InvalidTransferError < StandardError; end
