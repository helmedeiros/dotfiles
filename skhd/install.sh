#!/bin/sh
#
# skhd Install Script
# Symlinks the skhd directory into ~/.config/skhd and starts the service

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

# Start skhd service if installed and not already running
if command -v skhd > /dev/null 2>&1; then
  if ! pgrep -x skhd > /dev/null 2>&1; then
    printf "Starting skhd service.\n"
    skhd --start-service
  else
    printf "skhd already running.\n"
  fi
else
  printf "skhd not installed yet. Run 'brew bundle' first.\n"
fi

printf "skhd config installation complete.\n"
