#!/bin/sh
#

if test ! $(pgrep -f "Dropbox.app")
then
 open /Applications/Dropbox.app
fi
