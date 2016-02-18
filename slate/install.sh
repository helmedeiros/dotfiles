#!/bin/sh
#
cd "$(dirname "$0")/.."
DOTFILES_ROOT=$(pwd -P)

cp $DOTFILES_ROOT/slate/.slate $HOME
