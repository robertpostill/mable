require 'csv'
require 'bigdecimal'

# Responsible for parsing CSV files into domain objects.
class CsvLoader
  def self.load_accounts(file_path)
    new.load_accounts(file_path)
  end

  def self.load_transfers(file_path)
    new.load_transfers(file_path)
  end

  def load_accounts(file_path)
    rows = parse(file_path)
    rows.map do |row|
      raise "Invalid account row: #{row.inspect}" unless row.length >= 2

      account_number = row[0].strip
      balance        = BigDecimal(row[1].strip)
      Account.new(account_number, balance)
    end
  end

  def load_transfers(file_path)
    rows = parse(file_path)
    rows.map do |row|
      raise "Invalid transfer row: #{row.inspect}" unless row.length >= 3

      Transfer.new(row[0].strip, row[1].strip, BigDecimal(row[2].strip))
    end
  end

  private

  def parse(file_path)
    raise "File not found: #{file_path}" unless File.exist?(file_path)

    CSV.read(file_path).reject { |row| row.all?(&:nil?) }
  end
end
