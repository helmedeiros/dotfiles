#!/bin/sh
#
# Keyboard text replacements
#
# Exports macOS keyboard text substitutions (System Settings > Keyboard >
# Text Replacements) to ~/.dot-secrets. Replacement snippets are personal
# and often sensitive text, so they're kept out of this public repo.

set -e

DOT_SECRETS_ROOT="${DOT_SECRETS_ROOT:-$HOME/.dot-secrets}"
TARGET_DIR="$DOT_SECRETS_ROOT/keyboard"
TARGET_FILE="$TARGET_DIR/text-replacements.plist"

if [ ! -d "$DOT_SECRETS_ROOT" ]; then
  echo "  ~/.dot-secrets not found. Run script/bootstrap first."
  exit 0
fi

TMP_GLOBAL="$(mktemp)"
trap 'rm -f "$TMP_GLOBAL"' EXIT

defaults export NSGlobalDomain "$TMP_GLOBAL"

mkdir -p "$TARGET_DIR"
plutil -create xml1 "$TARGET_FILE"
plutil -insert NSUserDictionaryReplacementItems -xml \
  "$(plutil -extract NSUserDictionaryReplacementItems xml1 -o - "$TMP_GLOBAL")" \
  "$TARGET_FILE"

echo "  Exported keyboard text replacements to $TARGET_FILE"
