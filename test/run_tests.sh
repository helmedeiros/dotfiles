#!/bin/bash
#
# run_tests.sh
#
# Run all tests for the dotfiles repository. Walks every test block even if
# one fails so the full picture is visible in one run; exits non-zero at the
# end if any block reported failures.

FAILED=0

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if bats is installed
if ! command -v bats &> /dev/null; then
  echo -e "${RED}Error: bats is not installed${NC}"
  echo -e "${YELLOW}Please install bats with: brew install bats-core${NC}"
  exit 1
fi

# Get the directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Get the root of the dotfiles repository
DOTFILES_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Run all tests
echo -e "${BLUE}=== Running all tests ===${NC}"

# Run shellcheck lint on shell scripts
echo -e "${BLUE}=== Running shellcheck ===${NC}"
if command -v shellcheck &> /dev/null; then
  SHELL_SCRIPTS=()
  for f in "${DOTFILES_DIR}"/bin/*; do
    [ -f "$f" ] || continue
    head -1 "$f" | grep -qE '^#!.*\b(sh|bash)\b' && SHELL_SCRIPTS+=("$f")
  done
  if [ ${#SHELL_SCRIPTS[@]} -gt 0 ]; then
    shellcheck -S warning "${SHELL_SCRIPTS[@]}" || FAILED=1
  fi
else
  echo -e "${YELLOW}shellcheck not installed, skipping lint${NC}"
fi

# Discover and run every test suite. Suites are found on disk rather than
# listed here: the previous version repeated this block once per topic, so a
# new topic's tests only ran if someone remembered to register them — a
# silent skip, which is the worst kind of test failure.
#
# A directory counts as a suite when it holds *_test.bats; that excludes
# mothers/, which is fixtures.
suites_run=0
for suite_dir in "${SCRIPT_DIR}"/*/; do
  suite="$(basename "$suite_dir")"
  compgen -G "${suite_dir}*_test.bats" > /dev/null || continue

  echo -e "${BLUE}=== Running ${suite} tests ===${NC}"
  bats "${suite_dir}"*_test.bats || FAILED=1
  suites_run=$((suites_run + 1))
done

if [ "$suites_run" -eq 0 ]; then
  echo -e "${RED}No test suites found under ${SCRIPT_DIR}${NC}"
  FAILED=1
else
  echo -e "${BLUE}=== Ran ${suites_run} test suites ===${NC}"
fi

if [ "$FAILED" -eq 0 ]; then
  echo -e "\n${GREEN}All tests completed successfully!${NC}"
else
  echo -e "\n${RED}One or more test blocks reported failures.${NC}"
fi
exit "$FAILED"
