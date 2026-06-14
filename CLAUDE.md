# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A Ruby banking service that processes account transfers from CSV files. The system loads account balances, processes transfer requests, and reports results with proper error handling for insufficient funds and unknown accounts.

## Development Commands

### Running Tests
```bash
bundle exec rspec                # Run test suite
rake spec                        # Alternative test runner
rake coverage                    # Run tests with SimpleCov coverage report
```

### Running the Application
```bash
ruby mable.rb <balances_csv> <transfers_csv>          # Direct execution
./bin/mable_test.sh                                   # Via wrapper script (checks dependencies)
rake run                                              # Via Rake (uses default CSV files)
BALANCES_FILE=file1.csv TRANSFERS_FILE=file2.csv rake run   # Custom CSV files
```

### Code Quality
```bash
rake rubocop                     # Run RuboCop linter
rake rubocop:auto_correct        # Auto-fix RuboCop issues
rake lint                        # Ruby syntax check
```

### CI Pipeline
```bash
rake ci                          # Full pipeline: lint → rubocop → coverage → run
rake                             # Default task: spec → run
```

### Other
```bash
rake clean                       # Remove coverage reports
rake help                        # List all available Rake tasks
```

## Architecture

### Core Domain Models

**Account** (`lib/account.rb`)
- Represents a bank account with a 16-digit number and BigDecimal balance
- Supports `debit(amount)` and `credit(amount)` operations
- Raises `InsufficientFundsError` when debiting more than available balance

**Transfer** (`lib/transfer.rb`)
- Struct holding: from_account_number, to_account_number, amount
- Represents a single transfer request

**TransferResult** (`lib/transfer_result.rb`)
- Struct recording transfer outcome: transfer, success flag, error_message
- Provides `success?` and `failure?` predicates
- Formats output with ✓ or ✗ symbols

**Ledger** (`lib/ledger.rb`)
- Central registry holding all accounts in a hash (keyed by account number)
- Processes individual transfers and batches of transfers
- Coordinates account lookups, validates amounts, and catches domain errors
- Returns `TransferResult` objects for each transfer attempt

### Service Layer

**BankingService** (`lib/banking_service.rb`)
- Top-level orchestrator that wires together loading, processing, and reporting
- Entry point for the application
- Manages the workflow: load accounts → process transfers → report results

**CsvLoader** (`lib/csv_loader.rb`)
- Parses CSV files into domain objects (Account and Transfer)
- Validates row structure and converts strings to BigDecimal

### Error Handling

Custom exceptions in `lib/errors.rb`:
- `InsufficientFundsError` - raised when debit exceeds account balance
- `UnknownAccountError` - raised when referencing non-existent account
- `InvalidTransferError` - raised for invalid transfer operations (e.g., non-positive amounts)

All transfer errors are caught by `Ledger#process_transfer` and converted to failed `TransferResult` objects.

## Key Design Patterns

1. **BigDecimal for Money**: All monetary values use `BigDecimal` to avoid floating-point precision issues
2. **Fail-Fast Validation**: Invalid operations raise exceptions immediately rather than returning error codes
3. **Result Objects**: Transfers return explicit success/failure results rather than raising exceptions at the service layer
4. **Dependency Injection**: `BankingService#run` accepts an `output:` parameter (defaults to `$stdout`) for testability

## Important Notes

- Account numbers are stored as strings to preserve leading zeros
- Transfer processing is transactional per-transfer (failed transfers don't affect account state)
- CSV files must have no headers; raw data rows only
- The ledger doesn't support concurrent access (single-threaded processing assumed)
