#!/bin/bash
#
# run_tests.sh
#
# Run all tests for the dotfiles repository

set -e

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
    shellcheck -S warning "${SHELL_SCRIPTS[@]}"
  fi
else
  echo -e "${YELLOW}shellcheck not installed, skipping lint${NC}"
fi

# Run lib tests
echo -e "${BLUE}=== Running lib tests ===${NC}"
if [ -f "${SCRIPT_DIR}/lib/status_test.bats" ]; then
  bats "${SCRIPT_DIR}/lib/status_test.bats"
else
  echo -e "${YELLOW}No lib tests found${NC}"
fi

# Run bin tests
echo -e "${BLUE}=== Running bin tests ===${NC}"
if compgen -G "${SCRIPT_DIR}/bin/*_test.bats" > /dev/null; then
  bats "${SCRIPT_DIR}/bin/"*_test.bats
else
  echo -e "${YELLOW}No bin tests found${NC}"
fi

# Run zoxide tests
echo -e "${BLUE}=== Running zoxide tests ===${NC}"
if compgen -G "${SCRIPT_DIR}/zoxide/*_test.bats" > /dev/null; then
  bats "${SCRIPT_DIR}/zoxide/"*_test.bats
else
  echo -e "${YELLOW}No zoxide tests found${NC}"
fi

# Run zsh-completion-generator tests
echo -e "${BLUE}=== Running zsh-completion-generator tests ===${NC}"
if compgen -G "${SCRIPT_DIR}/zsh-completion-generator/*_test.bats" > /dev/null; then
  bats "${SCRIPT_DIR}/zsh-completion-generator/"*_test.bats
else
  echo -e "${YELLOW}No zsh-completion-generator tests found${NC}"
fi

echo -e "\n${GREEN}All tests completed!${NC}"
