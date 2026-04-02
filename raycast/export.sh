#!/bin/sh
#
# Raycast
#
# Exports current Raycast settings to the dotfiles for version control.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
PLIST_FILE="$SCRIPT_DIR/com.raycast.macos.plist"

if ! [ -d "/Applications/Raycast.app" ]; then
  echo "  Raycast not installed. Nothing to export."
  exit 0
fi

echo "  Exporting Raycast settings."
defaults export com.raycast.macos "$PLIST_FILE"
echo "  Saved to $PLIST_FILE"
