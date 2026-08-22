#!/bin/sh
#
# Xcode
#
# The app itself comes from the Brewfile's `mas 'Xcode', id: 497799835` entry,
# which `bin/dot` installs via `brew bundle` before this script runs. This
# script does the part `brew bundle` cannot: activating the toolchain.
#
# Installing Xcode is not fully unattended, for two reasons:
#
#   1. `mas` writes a ~15 GB bundle into /Applications and shells out to sudo
#      for it, so a fresh install prompts for a password.
#   2. `mas` can only install apps already associated with the signed-in Apple
#      ID. On a brand-new Apple ID, "Get" Xcode once from the App Store GUI,
#      then `bin/dot` can install and update it from then on.
#
# Everything here is idempotent and skips cleanly when Xcode is absent, so a
# machine that does not want Xcode is not blocked by it.
set -e

XCODE_APP="${XCODE_APP:-/Applications/Xcode.app}"
XCODE_MAS_ID="497799835"
XCODE_DEVELOPER_DIR="$XCODE_APP/Contents/Developer"

# Run a command with sudo, but never hang waiting for a password that nobody is
# there to type — bin/dot is sometimes run non-interactively.
run_privileged() {
  if sudo -n true 2>/dev/null; then
    sudo "$@"
  elif [ -t 0 ]; then
    sudo "$@"
  else
    echo "  Needs sudo, skipping: sudo $*"
    return 1
  fi
}

if [ ! -d "$XCODE_APP" ]; then
  echo "  Xcode is not installed."
  echo "  brew bundle installs it from the Brewfile's mas entry; if that failed,"
  echo "  it is usually because the app is not yet tied to your Apple ID."
  echo "  Get it once from the App Store, then re-run dot:"
  echo "    open \"macappstores://apps.apple.com/app/id$XCODE_MAS_ID\""
  echo "    sudo mas install $XCODE_MAS_ID"
  exit 0
fi

# Point the command-line tools at the full Xcode. Without this, xcodebuild and
# anything that shells out to it keep using /Library/Developer/CommandLineTools
# and fail with "tool 'xcodebuild' requires Xcode".
if [ "$(xcode-select -p 2>/dev/null)" != "$XCODE_DEVELOPER_DIR" ]; then
  echo "  Selecting $XCODE_DEVELOPER_DIR as the active developer directory."
  run_privileged xcode-select -s "$XCODE_DEVELOPER_DIR" || exit 0
fi

# The license must be accepted before xcodebuild will do anything at all.
if ! xcodebuild -version >/dev/null 2>&1; then
  echo "  Accepting the Xcode license."
  run_privileged xcodebuild -license accept || exit 0
fi

# First-launch installs the bundled platform SDKs and toolchain packages.
if ! xcodebuild -checkFirstLaunchStatus >/dev/null 2>&1; then
  echo "  Running Xcode first-launch tasks (this can take a few minutes)."
  run_privileged xcodebuild -runFirstLaunch || exit 0
fi

echo "  Xcode ready: $(xcodebuild -version 2>/dev/null | head -1)"
