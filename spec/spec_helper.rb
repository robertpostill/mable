if ENV['COVERAGE']
  require 'simplecov'

  SimpleCov.start do
    add_filter '/spec/'

    add_group 'Account',  'lib/account'
    add_group 'Transfers', 'lib/transfer'
    add_group 'Core',    'lib/ledger'
    add_group 'Error', 'lib/errors'
    add_group 'IO',      'lib/csv_loader'
    add_group 'Service', 'lib/banking_service'

    minimum_coverage 90
    track_files 'lib/**/*.rb'
  end
end

require 'bigdecimal'
require 'bigdecimal/util'
require 'simplecov'

require_relative '../lib/errors'
require_relative '../lib/account'
require_relative '../lib/transfer'
require_relative '../lib/transfer_result'
require_relative '../lib/ledger'
require_relative '../lib/csv_loader'
require_relative '../lib/banking_service'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.order = :random
  config.warnings = true
end
