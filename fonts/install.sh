#!/bin/sh
#
cd "$(dirname "$0")/.." || exit 1
DOTFILES_ROOT=$(pwd -P)

mkdir -p "$HOME/Library/Fonts"
cp "$DOTFILES_ROOT"/fonts/files/* "$HOME/Library/Fonts"
