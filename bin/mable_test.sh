#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------------------
# Mable Banking Service — runner script
# Usage: ./bin/mable_test.sh [balances_csv] [transfers_csv]
# Defaults to the sample files included in the project.
# ---------------------------------------------------------------------------

BALANCES_FILE="${1:-mable_account_balances.csv}"
TRANSFERS_FILE="${2:-mable_transactions.csv}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # no colour

info()    { echo -e "${GREEN}[INFO]${NC}  $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# ---------------------------------------------------------------------------
# 1. Check Ruby is installed
# ---------------------------------------------------------------------------
info "Checking Ruby installation..."

if ! command -v ruby &>/dev/null; then
  error "Ruby is not installed or not on your PATH."
  echo
  echo "  Install options:"
  echo "    macOS:   brew install ruby"
  echo "    Ubuntu:  sudo apt-get install ruby"
  echo "    rbenv:   rbenv install \$(rbenv install -l | grep -v - | tail -1)"
  echo "    rvm:     rvm install ruby"
  echo "    Windows: https://rubyinstaller.org"
  exit 1
fi

RUBY_VERSION="$(ruby --version)"
info "Found: ${RUBY_VERSION}"

# Warn if below minimum recommended version (3.0)
RUBY_MAJOR="$(ruby -e 'print RUBY_VERSION.split(".")[0].to_i')"
RUBY_MINOR="$(ruby -e 'print RUBY_VERSION.split(".")[1].to_i')"
if [[ "$RUBY_MAJOR" -lt 3 ]]; then
  warn "Ruby 3.0+ is recommended (you have ${RUBY_VERSION})."
fi

# ---------------------------------------------------------------------------
# 2. Check Bundler and install gems
# ---------------------------------------------------------------------------
info "Checking Bundler..."

if ! command -v bundle &>/dev/null; then
  warn "Bundler not found — installing..."
  gem install bundler --no-document
fi

info "Installing gems via Bundler..."
bundle install --quiet

# ---------------------------------------------------------------------------
# 3. Validate input files
# ---------------------------------------------------------------------------
info "Validating input files..."

missing=0
for f in "$BALANCES_FILE" "$TRANSFERS_FILE"; do
  if [[ ! -f "$f" ]]; then
    error "File not found: $f"
    missing=1
  fi
done

if [[ "$missing" -ne 0 ]]; then
  echo
  echo "  Usage: $0 [balances_csv] [transfers_csv]"
  exit 1
fi

info "Balances file:  ${BALANCES_FILE}"
info "Transfers file: ${TRANSFERS_FILE}"

# ---------------------------------------------------------------------------
# 4. Run the program
# ---------------------------------------------------------------------------
echo
info "Running Mable Banking Service..."
echo "============================================================"
ruby mable.rb "$BALANCES_FILE" "$TRANSFERS_FILE"
echo "============================================================"

info "Done."
