#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------------------
# Mable Banking Service — runner script
# Usage: bin/mable_test.sh [balances_csv] [transfers_csv]
# Defaults to the sample files included in the project.
# Run from the project root, or from anywhere (script resolves its own root).
# ---------------------------------------------------------------------------

BALANCES_FILE="${1:-mable_account_balances.csv}"
TRANSFERS_FILE="${2:-mable_transactions.csv}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

info()    { echo -e "${GREEN}[INFO]${NC}  $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*" >&2; }
section() { echo -e "\n${CYAN}==== $* ====${NC}"; }

# ---------------------------------------------------------------------------
# Resolve project root (the directory above bin/)
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${PROJECT_ROOT}"

# ---------------------------------------------------------------------------
# 1. Check Ruby is installed
# ---------------------------------------------------------------------------
section "Ruby"

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

RUBY_MAJOR="$(ruby -e 'print RUBY_VERSION.split(".")[0].to_i')"
if [[ "$RUBY_MAJOR" -lt 3 ]]; then
  warn "Ruby 3.0+ is recommended (you have ${RUBY_VERSION})."
fi

# ---------------------------------------------------------------------------
# 2. Check Bundler and install gems (includes simplecov + rake)
# ---------------------------------------------------------------------------
section "Dependencies"

if ! command -v bundle &>/dev/null; then
  warn "Bundler not found — installing..."
  gem install bundler --no-document
fi

info "Installing gems..."
bundle install --quiet

# ---------------------------------------------------------------------------
# 3. Validate input files
# ---------------------------------------------------------------------------
section "Input Files"

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
# 4. Run the project
# ---------------------------------------------------------------------------
section "Executing"

BALANCES_FILE="$BALANCES_FILE" TRANSFERS_FILE="$TRANSFERS_FILE" bundle exec rake run

section "Done"
