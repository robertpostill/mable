# frozen_string_literal: true

# Top-level service that wires loading, ledger management and reporting together.
class BankingService
  attr_reader :ledger

  def initialize
    @ledger = Ledger.new
  end

  def load_accounts(file_path)
    accounts = CsvLoader.load_accounts(file_path)
    accounts.each { |account| @ledger.add_account(account) }
    accounts
  end

  def process_transfers(file_path)
    transfers = CsvLoader.load_transfers(file_path)
    @ledger.process_transfers(transfers)
  end

  def run(balances_file:, transfers_file:, output: $stdout)
    output.puts "Loading account balances from: #{balances_file}"
    load_accounts(balances_file)
    output.puts '=== Initial Account Balances ==='
    ledger.accounts.each_value do |account|
      output.puts "  #{account.number}  #{account.formatted_balance}"
    end
    output.puts "Loaded #{ledger.accounts.size} accounts.\n\n"

    output.puts "Processing transfers from: #{transfers_file}"
    results = process_transfers(transfers_file)
    output.puts

    report(results, output: output)
  end

  def report(results, output: $stdout)
    output.puts '=== Transfer Results ==='
    results.each { |r| output.puts "  #{r}" }

    successes = results.count(&:success?)
    failures  = results.count(&:failure?)
    output.puts "\n#{successes} succeeded, #{failures} failed.\n\n"

    output.puts '=== Final Account Balances ==='
    ledger.accounts.each_value do |account|
      output.puts "  #{account.number}  #{account.formatted_balance}"
    end
  end
end
