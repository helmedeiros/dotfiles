#!/bin/sh
#
# Raycast
#
# Installs Raycast settings from exported config if available.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
CONFIG_FILE="$SCRIPT_DIR/raycast.rayconfig"

if ! command -v raycast > /dev/null 2>&1 && ! [ -d "/Applications/Raycast.app" ]; then
  echo "  Raycast not installed. Skipping configuration."
  exit 0
fi

if [ -f "$CONFIG_FILE" ]; then
  echo "  Importing Raycast settings."
  open "$CONFIG_FILE"
else
  echo "  No Raycast config found. To export your settings:"
  echo "    Raycast > Settings > Advanced > Export"
  echo "  Save the .rayconfig file to: $SCRIPT_DIR/raycast.rayconfig"
fi
