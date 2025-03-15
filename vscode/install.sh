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
echo -e "${BLUE}=== Installing VSCode settings ===${NC}"
if [ -f "$SCRIPT_DIR/settings.json.symlink" ]; then
  if [ -f "$VSCODE_DIR/settings.json" ]; then
    echo -e "${YELLOW}Backing up existing VSCode settings...${NC}"
    cp "$VSCODE_DIR/settings.json" "$VSCODE_DIR/settings.json.backup"
  fi
  echo -e "${GREEN}Installing VSCode settings...${NC}"
  cp "$SCRIPT_DIR/settings.json.symlink" "$VSCODE_DIR/settings.json"
else
  echo -e "${RED}VSCode settings file not found!${NC}"
fi

# Install VSCode extensions
echo -e "\n${BLUE}=== Installing VSCode extensions ===${NC}"
if [ -f "$SCRIPT_DIR/extensions.txt" ]; then
  # Check if VSCode is installed
  if command -v code &> /dev/null; then
    echo -e "${GREEN}Installing VSCode extensions...${NC}"
    while IFS= read -r line || [[ -n "$line" ]]; do
      # Skip comments and empty lines
      if [[ "$line" =~ ^#.*$ ]] || [[ -z "$line" ]]; then
        continue
      fi
      echo -e "${GREEN}Installing extension: $line${NC}"
      code --install-extension "$line" --force
    done < "$SCRIPT_DIR/extensions.txt"
  else
    echo -e "${RED}VSCode not found! Skipping extension installation.${NC}"
  fi
else
  echo -e "${RED}Extensions list not found!${NC}"
fi

echo -e "\n${GREEN}VSCode setup completed!${NC}" 