#!/bin/sh
#
# GitHub CLI (gh)
#
# This checks if GitHub CLI is installed and installs it via Homebrew if needed.

# Check for gh
if test ! $(which gh)
then
  echo "  Installing GitHub CLI for you."
  brew install gh
fi

# Check if gh is authenticated
if ! gh auth status &>/dev/null
then
  echo "  GitHub CLI is installed but not authenticated."
  echo "  Run 'gh auth login' to authenticate with GitHub."
fi

exit 0
