#!/bin/sh
#
# Amphetamine
set -e

# Amphetamine is Mac App Store-only (no Homebrew cask); it is installed via the
# `mas 'Amphetamine', id: 937984704` entry in the Brewfile. `mas` can only
# install it once the app is associated with the signed-in Apple ID, so on a
# fresh machine "Get" it once from the App Store GUI first.
if mas list 2>/dev/null | grep -q 937984704
then
  echo "  Starting an Amphetamine session for you."
  osascript -e 'tell application "Amphetamine" to start new session'
else
  echo "  Amphetamine not installed yet — skipping. Get it from the App Store, then re-run dot."
fi
