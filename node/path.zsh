#!/bin/zsh
#
# Node.js and NVM configuration
#

# Set NVM directory
export NVM_DIR="$HOME/.nvm"

# Load NVM if it exists, but don't fail if it doesn't
if [ -s "$NVM_DIR/nvm.sh" ]; then
  # This loads nvm
  . "$NVM_DIR/nvm.sh" || true
fi

# Load NVM bash completion if it exists
if [ -s "$NVM_DIR/bash_completion" ]; then
  # This loads nvm bash_completion
  . "$NVM_DIR/bash_completion" || true
fi
