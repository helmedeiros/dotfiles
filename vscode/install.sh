#!/bin/bash
#
# VSCode setup
#
# This script installs VSCode settings and extensions

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# VSCode settings directory
VSCODE_DIR="$HOME/Library/Application Support/Code/User"

# Create directory if it doesn't exist
mkdir -p "$VSCODE_DIR"

# Install VSCode settings
printf '%b\n' "${BLUE}=== Installing VSCode settings ===${NC}"
if [ -f "$SCRIPT_DIR/settings.json.symlink" ]; then
  if [ -f "$VSCODE_DIR/settings.json" ]; then
    printf '%b\n' "${YELLOW}Backing up existing VSCode settings...${NC}"
    cp "$VSCODE_DIR/settings.json" "$VSCODE_DIR/settings.json.backup"
  fi
  printf '%b\n' "${GREEN}Installing VSCode settings...${NC}"
  cp "$SCRIPT_DIR/settings.json.symlink" "$VSCODE_DIR/settings.json"
else
  printf '%b\n' "${RED}VSCode settings file not found!${NC}"
fi

# Install VSCode extensions
printf '%b\n' "\n${BLUE}=== Installing VSCode extensions ===${NC}"
extensions_failed=0
if command -v code &> /dev/null; then
  # shellcheck source=../lib/editor-extensions.sh
  . "$SCRIPT_DIR/../lib/editor-extensions.sh"
  install_editor_extensions code "$SCRIPT_DIR/extensions.txt" "VSCode" || extensions_failed=1
else
  printf '%b\n' "${RED}VSCode not found! Skipping extension installation.${NC}"
fi

if [ "$extensions_failed" -ne 0 ]; then
  printf '%b\n' "\n${RED}VSCode setup finished with extension failures.${NC}"
  exit 1
fi

printf '%b\n' "\n${GREEN}VSCode setup completed!${NC}"
