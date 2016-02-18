#!/bin/sh
#
cd "$(dirname "$0")/.."
DOTFILES_ROOT=$(pwd -P)

cp $DOTFILES_ROOT/slate/.slate $HOME

if test ! $(pgrep -f "Slate.app")
then
 open /Applications/Slate.app
fi
