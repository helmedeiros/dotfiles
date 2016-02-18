#!/bin/sh
#
cd "$(dirname "$0")/.."
DOTFILES_ROOT=$(pwd -P)

cp $DOTFILES_ROOT/slate/.slate $HOME

if test ! $(pgrep -f "Slate.app")
then
 open /Applications/Slate.app
fi


osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/Slate.app", hidden:false}'  > /dev/null 2>&1
