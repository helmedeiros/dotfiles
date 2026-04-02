#!/bin/sh
#
# Raycast
#
# Imports Raycast settings from an exported plist if available.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
PLIST_FILE="$SCRIPT_DIR/com.raycast.macos.plist"

if ! [ -d "/Applications/Raycast.app" ]; then
  echo "  Raycast not installed. Skipping configuration."
  exit 0
fi

if [ -f "$PLIST_FILE" ]; then
  echo "  Importing Raycast settings."
  defaults import com.raycast.macos "$PLIST_FILE"
  echo "  Raycast settings imported. Restart Raycast to apply."
else
  echo "  No Raycast config found. Run raycast/export.sh to snapshot your settings."
fi
