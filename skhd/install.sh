#!/bin/sh
#
# skhd Install Script
# Symlinks the skhd directory into ~/.config/skhd and starts or restarts the service

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
CONFIG_DIR="$HOME/.config/skhd"

printf "Installing skhd config.\n"

if [ -L "$CONFIG_DIR" ]; then
  printf "Removing existing skhd symlink.\n"
  rm "$CONFIG_DIR"
elif [ -d "$CONFIG_DIR" ]; then
  printf "Removing existing skhd config folder.\n"
  rm -rf "$CONFIG_DIR"
fi

mkdir -p "$HOME/.config"

printf "Creating symlink for skhd folder.\n"
ln -s "$SCRIPT_DIR" "$CONFIG_DIR"

# skhd's hotloader does not see edits made through the symlinked config dir,
# so a running service must be restarted to pick up skhdrc changes.
if command -v skhd > /dev/null 2>&1; then
  if pgrep -x skhd > /dev/null 2>&1; then
    printf "Restarting skhd service to apply config.\n"
    skhd --restart-service
  else
    printf "Starting skhd service.\n"
    skhd --start-service
  fi
else
  printf "skhd not installed yet. Run 'brew bundle' first.\n"
fi

printf "skhd config installation complete.\n"
