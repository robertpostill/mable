# frozen_string_literal: true

require 'logger'

# Top-level service that wires loading, ledger management and reporting together.
class BankingService
  attr_reader :ledger, :logger

  def initialize(logger: Logger.new($stdout))
    @ledger = Ledger.new
    @logger = logger
    @logger.formatter = proc do |_severity, _datetime, _progname, msg|
      "#{msg}\n"
    end
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

  def run(balances_file:, transfers_file:)
    logger.info "Loading account balances from: #{balances_file}"
    load_accounts(balances_file)
    logger.info '=== Initial Account Balances ==='
    ledger.accounts.each_value do |account|
      logger.info "  #{account.number}  #{account.formatted_balance}"
    end
    logger.info "Loaded #{ledger.accounts.size} accounts.\n\n"

    logger.info "Processing transfers from: #{transfers_file}"
    results = process_transfers(transfers_file)
    logger.info ''

    report(results)
  end

  def report(results)
    logger.info '=== Transfer Results ==='
    results.each { |r| logger.info "  #{r}" }

    successes = results.count(&:success?)
    failures  = results.count(&:failure?)
    logger.info "\n#{successes} succeeded, #{failures} failed.\n\n"

    logger.info '=== Final Account Balances ==='
    ledger.accounts.each_value do |account|
      logger.info "  #{account.number}  #{account.formatted_balance}"
    end
  end
end
