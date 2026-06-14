# frozen_string_literal: true

require 'money'

Money.default_currency = Money::Currency.new('AUD')
Money.rounding_mode = BigDecimal::ROUND_HALF_UP

require_relative 'lib/errors'
require_relative 'lib/account'
require_relative 'lib/transfer'
require_relative 'lib/transfer_result'
require_relative 'lib/ledger'
require_relative 'lib/csv_loader'
require_relative 'lib/banking_service'

if __FILE__ == $PROGRAM_NAME
  if ARGV.length != 2
    warn 'Usage: ruby mable.rb <balances_csv> <transfers_csv>'
    exit 1
  end

  balances_file  = ARGV[0]
  transfers_file = ARGV[1]

  BankingService.new.run(
    balances_file: balances_file,
    transfers_file: transfers_file
  )
end
