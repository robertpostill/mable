# frozen_string_literal: true

require 'csv'
require 'bigdecimal'

# Responsible for parsing CSV files into domain objects in batches.
class CsvLoader
  BATCH_SIZE = 50

  def self.load_accounts(file_path, &)
    new.load_accounts(file_path, &)
  end

  def self.load_transfers(file_path, &)
    new.load_transfers(file_path, &)
  end

  def load_accounts(file_path)
    each_batch(file_path) do |rows|
      yield rows.map { |row| parse_account(row) }
    end
  end

  def load_transfers(file_path)
    each_batch(file_path) do |rows|
      yield rows.map { |row| parse_transfer(row) }
    end
  end

  private

  def each_batch(file_path)
    raise "File not found: #{file_path}" unless File.exist?(file_path)

    CSV.foreach(file_path).each_slice(BATCH_SIZE) do |rows|
      data = rows.reject { |row| row.all?(&:nil?) }
      yield data unless data.empty?
    end
  end

  def parse_account(row)
    raise "Invalid account row: #{row.inspect}" unless row.length >= 2

    Account.new(row[0].strip, BigDecimal(row[1].strip))
  end

  def parse_transfer(row)
    raise "Invalid transfer row: #{row.inspect}" unless row.length >= 3

    Transfer.new(row[0].strip, row[1].strip, BigDecimal(row[2].strip))
  end
end
