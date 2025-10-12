#!/bin/zsh
#
# Node.js and NVM configuration
#

# Set NVM directory
export NVM_DIR="$HOME/.nvm"

# Disable NVM auto-use completely
export NVM_AUTO_USE=false

# Lazy load NVM for better startup performance
if [ -s "$NVM_DIR/nvm.sh" ]; then
  # Create lazy loading function for nvm
  nvm() {
    unset -f nvm
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    nvm "$@"
  }

  # Create lazy loading for node and npm
  node() {
    unset -f node
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    node "$@"
  }

  npm() {
    unset -f npm
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    npm "$@"
  }
fi
