#!/bin/sh
# Karabiner Elements Install Script
# Nefari0uss

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)" # Get the path of the folder the file is in.
CONFIG_DIR=$HOME/.config/karabiner

printf 'Script Dir %s\n' "$SCRIPT_DIR"
printf 'Config_dir %s\n' "$CONFIG_DIR"

printf "\nInstalling Karabiner Elements config.\n"

if [ -L "$CONFIG_DIR" ]; then
  printf "Removing existing karabiner symlink.\n"
  rm "$CONFIG_DIR"
elif [ -d "$CONFIG_DIR" ]; then
  printf "Deleting existing karabiner config folder.\n"
  rm -rf "$CONFIG_DIR"
fi

mkdir -p "$HOME/.config"

printf "Making symlink for karabiner folder.\n"
ln -s "$SCRIPT_DIR" "$CONFIG_DIR"

printf "Karabiner Elements config installation complete.\n"
