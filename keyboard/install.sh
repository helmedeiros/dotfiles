#!/bin/sh
#
# Keyboard text replacements
#
# Imports macOS keyboard text substitutions from an exported plist in
# ~/.dot-secrets, if available.

set -e

DOT_SECRETS_ROOT="${DOT_SECRETS_ROOT:-$HOME/.dot-secrets}"
SOURCE_FILE="$DOT_SECRETS_ROOT/keyboard/text-replacements.plist"

if [ -f "$SOURCE_FILE" ]; then
  echo "  Importing keyboard text replacements."
  defaults import NSGlobalDomain "$SOURCE_FILE"
  echo "  Imported. Log out and back in (or restart apps) to pick them up everywhere."
else
  echo "  No keyboard text replacements found in .dot-secrets. Run keyboard/export.sh to snapshot your current ones."
fi
