#!/bin/bash
#
# Cursor setup
#
# This script installs Cursor settings and extensions

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Cursor settings directory
CURSOR_DIR="$HOME/Library/Application Support/Cursor/User"

# Create directory if it doesn't exist
mkdir -p "$CURSOR_DIR"

# Install Cursor settings
echo -e "${BLUE}=== Installing Cursor settings ===${NC}"
if [ -f "$SCRIPT_DIR/settings.json.symlink" ]; then
  if [ -f "$CURSOR_DIR/settings.json" ]; then
    echo -e "${YELLOW}Backing up existing Cursor settings...${NC}"
    cp "$CURSOR_DIR/settings.json" "$CURSOR_DIR/settings.json.backup"
  fi
  echo -e "${GREEN}Installing Cursor settings...${NC}"
  cp "$SCRIPT_DIR/settings.json.symlink" "$CURSOR_DIR/settings.json"
else
  echo -e "${RED}Cursor settings file not found!${NC}"
fi

# Install Cursor extensions
echo -e "\n${BLUE}=== Installing Cursor extensions ===${NC}"
if [ -f "$SCRIPT_DIR/extensions.txt" ]; then
  # Check if Cursor is installed
  if command -v cursor &> /dev/null; then
    echo -e "${GREEN}Installing Cursor extensions...${NC}"
    while IFS= read -r line || [[ -n "$line" ]]; do
      # Skip comments and empty lines
      if [[ "$line" =~ ^#.*$ ]] || [[ -z "$line" ]]; then
        continue
      fi
      echo -e "${GREEN}Installing extension: $line${NC}"
      cursor --install-extension "$line" --force
    done < "$SCRIPT_DIR/extensions.txt"
  else
    echo -e "${RED}Cursor not found! Skipping extension installation.${NC}"
  fi
else
  echo -e "${RED}Extensions list not found!${NC}"
fi

echo -e "\n${GREEN}Cursor setup completed!${NC}" 