# frozen_string_literal: true

require 'rake'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

BALANCES_FILE  = ENV.fetch('BALANCES_FILE',  'mable_account_balances.csv')
TRANSFERS_FILE = ENV.fetch('TRANSFERS_FILE', 'mable_transactions.csv')

def require_app
  require 'bigdecimal'
  require 'bigdecimal/util'
  require_relative 'lib/errors'
  require_relative 'lib/account'
  require_relative 'lib/transfer'
  require_relative 'lib/transfer_result'
  require_relative 'lib/ledger'
  require_relative 'lib/csv_loader'
  require_relative 'lib/banking_service'
end

# ---------------------------------------------------------------------------
# Default
# ---------------------------------------------------------------------------

desc 'Run tests then execute the banking service (default)'
task default: %i[spec run]

# ---------------------------------------------------------------------------
# spec — run RSpec suite
# ---------------------------------------------------------------------------

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = '--format documentation --color'
end

# ---------------------------------------------------------------------------
# coverage — run RSpec with SimpleCov enabled
# ---------------------------------------------------------------------------

desc 'Run specs with SimpleCov code coverage'
task :coverage do
  ENV['COVERAGE'] = 'true'
  Rake::Task[:spec].invoke
end

# ---------------------------------------------------------------------------
# rubocop — lint and style checking
# ---------------------------------------------------------------------------

RuboCop::RakeTask.new(:rubocop) do |t|
  t.options = ['--display-cop-names', '--color']
end

RuboCop::RakeTask.new('rubocop:auto_correct') do |t|
  t.options = ['--autocorrect', '--color']
end

# ---------------------------------------------------------------------------
# run — execute the banking service against CSV files
# ---------------------------------------------------------------------------

desc 'Run the banking service (set BALANCES_FILE / TRANSFERS_FILE to override)'
task :run do
  require_app
  BankingService.new.run(
    balances_file: BALANCES_FILE,
    transfers_file: TRANSFERS_FILE
  )
end

# ---------------------------------------------------------------------------
# lint — Ruby syntax check across all lib files
# ---------------------------------------------------------------------------

desc 'Check Ruby syntax for all files in lib/'
task :lint do
  files = FileList['lib/**/*.rb', 'mable.rb']
  errors = []

  files.each do |f|
    result = system("ruby -c #{f} > /dev/null 2>&1")
    errors << f unless result
  end

  if errors.empty?
    puts "Syntax OK — #{files.size} file(s) checked."
  else
    abort "Syntax errors in:\n#{errors.map { |f| "  #{f}" }.join("\n")}"
  end
end

# ---------------------------------------------------------------------------
# clean — remove generated artefacts
# ---------------------------------------------------------------------------

desc 'Remove coverage reports and other generated files'
task :clean do
  FileUtils.rm_rf('coverage')
  puts 'Cleaned coverage/.'
end

# ---------------------------------------------------------------------------
# ci — full pipeline: lint → rubocop → coverage → run
# ---------------------------------------------------------------------------

desc 'Full CI pipeline: lint, rubocop, tests with coverage, then run'
task ci: %i[lint rubocop coverage run]

# ---------------------------------------------------------------------------
# help (mirrors `rake -T` but friendlier)
# ---------------------------------------------------------------------------

desc 'List all available tasks with descriptions'
task :help do
  puts
  puts 'Mable Banking Service — available Rake tasks'
  puts '-' * 50
  Rake::Task.tasks.each do |t|
    next if t.comment.nil? || t.comment.empty?

    printf "  %-30s %s\n", "rake #{t.name}", t.comment
  end
  puts
  puts 'Environment variables:'
  puts '  BALANCES_FILE   path to account balances CSV (default: mable_account_balances.csv)'
  puts '  TRANSFERS_FILE  path to transfers CSV        (default: mable_transactions.csv)'
  puts
end
