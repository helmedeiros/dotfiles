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
    source "$NVM_DIR/nvm.sh" --no-use
    
    # Check if NVM loaded successfully
    if command -v nvm &> /dev/null; then
      echo "NVM loaded successfully (auto-use disabled)"
      return 0
    else
      echo "Warning: NVM did not load properly"
      return 1
    fi
  else
    echo "Warning: NVM installation not found at $NVM_DIR/nvm.sh"
    return 1
  fi
}

# Load NVM safely
load_nvm_safely

# Only try to use a Node.js version if NVM loaded successfully
if command -v nvm &> /dev/null; then
  # Check if any Node.js versions are installed with NVM
  if [ -n "$(nvm ls 2>/dev/null | grep -v "N/A" | grep -v "system" | grep -v "not installed" | head -n1)" ]; then
    # If there's at least one version installed, use the latest LTS version or latest available
    if nvm ls --lts 2>/dev/null | grep -q "v"; then
      echo "Using latest LTS Node.js version"
      nvm use --lts --silent || echo "Failed to use LTS version, falling back to system Node.js"
    else
      echo "Using latest available Node.js version"
      nvm use node --silent || echo "Failed to use latest version, falling back to system Node.js"
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
  source "$NVM_DIR/bash_completion"
fi
