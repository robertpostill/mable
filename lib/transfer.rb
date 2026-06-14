# frozen_string_literal: true

# Represents a single transfer request: from account → to account for an amount.
Transfer = Struct.new(:from_account_number, :to_account_number, :amount) do
  def to_s
    "Transfer(#{from_account_number} → #{to_account_number}, #{format('$%.2f', amount)})"
  end
end
