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

# App bundle, overridable so tests can point at a stub instead of
# /Applications. The CLI ships inside the bundle.
CURSOR_APP="${CURSOR_APP:-/Applications/Cursor.app}"
CURSOR_CLI="$CURSOR_APP/Contents/Resources/app/bin/cursor"

if ! [ -d "$CURSOR_APP" ]; then
  echo -e "${RED}Cursor is not installed. Skipping configuration.${NC}"
  exit 0
fi

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
extensions_failed=0
if [ -x "$CURSOR_CLI" ]; then
  # shellcheck source=../lib/editor-extensions.sh
  . "$SCRIPT_DIR/../lib/editor-extensions.sh"
  install_editor_extensions "$CURSOR_CLI" "$SCRIPT_DIR/extensions.txt" "Cursor" || extensions_failed=1
else
  echo -e "${RED}Cursor CLI not found at $CURSOR_CLI! Skipping extension installation.${NC}"
fi

if [ "$extensions_failed" -ne 0 ]; then
  echo -e "\n${RED}Cursor setup finished with extension failures.${NC}"
  exit 1
fi

echo -e "\n${GREEN}Cursor setup completed!${NC}"
