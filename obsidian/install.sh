#!/bin/sh
# Obsidian Install Script
# Obsidian itself is installed via the Brewfile (cask 'obsidian').
# This seeds a vault's `.obsidian/` config from the tracked defaults so a fresh
# vault opens with a sensible setup (graph view, backlinks, wikilinks).
#
# Usage: obsidian/install.sh [VAULT_DIR]
#   VAULT_DIR defaults to $OBSIDIAN_VAULT or ~/Desktop/chatgpt-export/knowledge-graph

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
VAULT_DIR="${1:-${OBSIDIAN_VAULT:-$HOME/second-brain}}"
DEFAULTS="$SCRIPT_DIR/vault-defaults"

printf "Obsidian: ensuring cask is installed.\n"
if ! brew list --cask obsidian >/dev/null 2>&1; then
  brew install --cask obsidian
fi

if [ ! -d "$VAULT_DIR" ]; then
  printf "Vault dir %s not found; skipping config seed.\n" "$VAULT_DIR"
  exit 0
fi

# Seed .obsidian config by COPY (Obsidian writes to it at runtime; a symlink to a
# git-tracked dir would churn). Only fills in files that don't already exist.
mkdir -p "$VAULT_DIR/.obsidian"
for f in "$DEFAULTS"/*.json; do
  name="$(basename "$f")"
  if [ ! -f "$VAULT_DIR/.obsidian/$name" ]; then
    cp "$f" "$VAULT_DIR/.obsidian/$name"
    printf "  seeded .obsidian/%s\n" "$name"
  else
    printf "  kept existing .obsidian/%s\n" "$name"
  fi
done

printf "Obsidian config seeded into %s\n" "$VAULT_DIR"
printf "Open it: obsidian://open?path=%s\n" "$VAULT_DIR"
