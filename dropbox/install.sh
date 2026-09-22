#!/bin/sh
if [ ! -d "/Applications/Dropbox.app" ]; then
  echo "Dropbox not installed. Skipping."
  exit 0
fi

if [ -z "$(pgrep -f "Dropbox.app" | head -1)" ]; then
 open /Applications/Dropbox.app
fi
