# frozen_string_literal: true

# Represents a single bank account identified by a 16-digit account number.
class Account
  attr_reader :number, :balance

  def initialize(number, balance)
    @number  = number.to_s
    @balance = BigDecimal(balance.to_s)
  end

  def debit(amount)
    raise InsufficientFundsError.new(self, amount) if amount > @balance

    @balance -= amount
  end

  def credit(amount)
    @balance += amount
  end

  def sufficient_funds?(amount)
    @balance >= amount
  end

  def to_s
    "Account(#{number}, balance: #{formatted_balance})"
  end

  def formatted_balance
    format('$%.2f', balance)
  end
end
