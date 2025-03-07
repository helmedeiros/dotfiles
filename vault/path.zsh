#!/bin/zsh
#
# Add Vault to PATH if it exists in either location

if [ -d "/opt/homebrew/bin" ]; then
  # Apple Silicon path
  export PATH="/opt/homebrew/bin:$PATH"
else
  # Intel path
  export PATH="/usr/local/bin:$PATH"
fi 