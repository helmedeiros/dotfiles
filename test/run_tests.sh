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

# Run all tests
echo -e "${BLUE}=== Running all tests ===${NC}"

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

echo -e "\n${GREEN}All tests completed!${NC}"
