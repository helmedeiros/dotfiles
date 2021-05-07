#!/bin/sh
#
# Caffeine
set -e

# Check for Caffeine
if [[ $(brew list --cask) =~ caffeine ]]    
then
  echo "  Configuring Caffeine for you."
  osascript -e 'tell application "Caffeine" to turn on'
fi
