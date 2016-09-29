#!/bin/sh
if test ! $(pgrep -f "Dropbox.app" | head -1)
then
 open /Applications/Dropbox.app
fi
