#!/bin/sh
# Ghostty Install Script
# Symlinks the ghostty directory into ~/.config/ghostty

SCRIPT_LOCATION=$(greadlink -e $0)
SCRIPT_DIR=$(dirname $SCRIPT_LOCATION)
CONFIG_DIR=$HOME/.config/ghostty

printf "Installing Ghostty config.\n"

if [ -L $CONFIG_DIR ]; then
  printf "Removing existing ghostty symlink.\n"
  rm $CONFIG_DIR
elif [ -d $CONFIG_DIR ]; then
  printf "Removing existing ghostty config folder.\n"
  rm -rf $CONFIG_DIR
fi

if [ ! -d $HOME/.config ]; then
  printf "Creating config folder under $HOME.\n"
  mkdir -p $HOME/.config
fi

printf "Creating symlink for ghostty folder.\n"
ln -s $SCRIPT_DIR $CONFIG_DIR

printf "Ghostty config installation complete.\n"
