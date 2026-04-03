#!/bin/sh
#
# Yabai Install Script
# Symlinks the yabai directory into ~/.config/yabai and starts the service

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
CONFIG_DIR="$HOME/.config/yabai"

printf "Installing Yabai config.\n"

if [ -L "$CONFIG_DIR" ]; then
  printf "Removing existing yabai symlink.\n"
  rm "$CONFIG_DIR"
elif [ -d "$CONFIG_DIR" ]; then
  printf "Removing existing yabai config folder.\n"
  rm -rf "$CONFIG_DIR"
fi

mkdir -p "$HOME/.config"

printf "Creating symlink for yabai folder.\n"
ln -s "$SCRIPT_DIR" "$CONFIG_DIR"

# Start yabai service if installed and not already running
if command -v yabai > /dev/null 2>&1; then
  if ! pgrep -x yabai > /dev/null 2>&1; then
    printf "Starting yabai service.\n"
    yabai --start-service
  else
    printf "Yabai already running.\n"
  fi
else
  printf "Yabai not installed yet. Run 'brew bundle' first.\n"
fi

printf "Yabai config installation complete.\n"
