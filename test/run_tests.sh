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

# Run lib tests
echo -e "${BLUE}=== Running lib tests ===${NC}"
if compgen -G "${SCRIPT_DIR}/lib/*_test.bats" > /dev/null; then
  bats "${SCRIPT_DIR}/lib/"*_test.bats || FAILED=1
else
  echo -e "${YELLOW}No lib tests found${NC}"
fi

# Run bin tests
echo -e "${BLUE}=== Running bin tests ===${NC}"
if compgen -G "${SCRIPT_DIR}/bin/*_test.bats" > /dev/null; then
  bats "${SCRIPT_DIR}/bin/"*_test.bats || FAILED=1
else
  echo -e "${YELLOW}No bin tests found${NC}"
fi

# Run zoxide tests
echo -e "${BLUE}=== Running zoxide tests ===${NC}"
if compgen -G "${SCRIPT_DIR}/zoxide/*_test.bats" > /dev/null; then
  bats "${SCRIPT_DIR}/zoxide/"*_test.bats || FAILED=1
else
  echo -e "${YELLOW}No zoxide tests found${NC}"
fi

# Run claude tests
echo -e "${BLUE}=== Running claude tests ===${NC}"
if compgen -G "${SCRIPT_DIR}/claude/*_test.bats" > /dev/null; then
  bats "${SCRIPT_DIR}/claude/"*_test.bats || FAILED=1
else
  echo -e "${YELLOW}No claude tests found${NC}"
fi

# Run kubernetes tests
echo -e "${BLUE}=== Running kubernetes tests ===${NC}"
if compgen -G "${SCRIPT_DIR}/kubernetes/*_test.bats" > /dev/null; then
  bats "${SCRIPT_DIR}/kubernetes/"*_test.bats || FAILED=1
else
  echo -e "${YELLOW}No kubernetes tests found${NC}"
fi

# Run myke tests
echo -e "${BLUE}=== Running myke tests ===${NC}"
if compgen -G "${SCRIPT_DIR}/myke/*_test.bats" > /dev/null; then
  bats "${SCRIPT_DIR}/myke/"*_test.bats || FAILED=1
else
  echo -e "${YELLOW}No myke tests found${NC}"
fi

# Run pre-commit tests
echo -e "${BLUE}=== Running pre-commit tests ===${NC}"
if compgen -G "${SCRIPT_DIR}/pre-commit/*_test.bats" > /dev/null; then
  bats "${SCRIPT_DIR}/pre-commit/"*_test.bats || FAILED=1
else
  echo -e "${YELLOW}No pre-commit tests found${NC}"
fi

# Run node tests
echo -e "${BLUE}=== Running node tests ===${NC}"
if compgen -G "${SCRIPT_DIR}/node/*_test.bats" > /dev/null; then
  bats "${SCRIPT_DIR}/node/"*_test.bats || FAILED=1
else
  echo -e "${YELLOW}No node tests found${NC}"
fi

# Run sdkman tests
echo -e "${BLUE}=== Running sdkman tests ===${NC}"
if compgen -G "${SCRIPT_DIR}/sdkman/*_test.bats" > /dev/null; then
  bats "${SCRIPT_DIR}/sdkman/"*_test.bats || FAILED=1
else
  echo -e "${YELLOW}No sdkman tests found${NC}"
fi

# Run zsh-completion-generator tests
echo -e "${BLUE}=== Running zsh-completion-generator tests ===${NC}"
if compgen -G "${SCRIPT_DIR}/zsh-completion-generator/*_test.bats" > /dev/null; then
  bats "${SCRIPT_DIR}/zsh-completion-generator/"*_test.bats || FAILED=1
else
  echo -e "${YELLOW}No zsh-completion-generator tests found${NC}"
fi

# Run repo-wide lint tests
echo -e "${BLUE}=== Running lint tests ===${NC}"
if compgen -G "${SCRIPT_DIR}/lint/*_test.bats" > /dev/null; then
  bats "${SCRIPT_DIR}/lint/"*_test.bats || FAILED=1
else
  echo -e "${YELLOW}No lint tests found${NC}"
fi

if [ "$FAILED" -eq 0 ]; then
  echo -e "\n${GREEN}All tests completed successfully!${NC}"
else
  echo -e "\n${RED}One or more test blocks reported failures.${NC}"
fi
exit "$FAILED"
