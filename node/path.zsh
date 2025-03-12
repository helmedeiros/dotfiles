#!/bin/zsh
#
# Node.js and NVM configuration
#

# Set NVM directory
export NVM_DIR="$HOME/.nvm"

# Disable NVM auto-use completely
export NVM_AUTO_USE=false

# Function to safely load NVM without auto-use
load_nvm_safely() {
  # Check if NVM script exists
  if [ -s "$NVM_DIR/nvm.sh" ]; then
    # Source NVM but prevent it from running auto-use
    source "$NVM_DIR/nvm.sh" --no-use > /dev/null 2>&1
    
    # Check if NVM loaded successfully
    if command -v nvm &> /dev/null; then
      return 0
    else
      echo "Warning: NVM did not load properly" >&2
      return 1
    fi
  else
    echo "Warning: NVM installation not found at $NVM_DIR/nvm.sh" >&2
    return 1
  fi
}

# Load NVM safely
load_nvm_safely > /dev/null 2>&1

# Only try to use a Node.js version if NVM loaded successfully
if command -v nvm &> /dev/null; then
  # Check if any Node.js versions are installed with NVM
  if [ -n "$(nvm ls 2>/dev/null | grep -v "N/A" | grep -v "system" | grep -v "not installed" | head -n1)" ]; then
    # If there's at least one version installed, use the latest LTS version or latest available
    if nvm ls --lts 2>/dev/null | grep -q "v"; then
      nvm use --lts --silent > /dev/null 2>&1
    else
      nvm use node --silent > /dev/null 2>&1
    fi
  elif command -v node &> /dev/null; then
    # If system Node.js is available, use that
    echo "Using system Node.js: $(node -v)"
  else
    echo "No Node.js version found. You may want to install one with 'nvm install --lts'"
  fi
fi

# Load NVM bash completion if it exists
if [ -s "$NVM_DIR/bash_completion" ]; then
  # This loads nvm bash_completion
  source "$NVM_DIR/bash_completion" > /dev/null 2>&1
fi
