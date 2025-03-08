#!/usr/bin/env bash
#
# DBeaver configuration and install.
source $(dirname $0)/../secrets/dots.sh

set -e

function configure_dbeaver() {
  local source_dir="$1"
  local dbeaver_version=$(ls -1 /Applications/DBeaver.app/Contents/Info.plist 2>/dev/null | wc -l)
  
  if [ "$dbeaver_version" -eq 0 ]; then
    echo "DBeaver is not installed. Please install it first with 'brew install --cask dbeaver-community'."
    return 1
  fi
  
  # Check for DBeaver configuration location (v22+)
  if [ -d "$HOME/Library/DBeaverData" ]; then
    echo "Found DBeaver configuration directory"
    
    # Create directories if they don't exist
    mkdir -p "$HOME/Library/DBeaverData/workspace6/.metadata/.plugins/org.jkiss.dbeaver.core"
    
    # Backup existing configuration if it exists
    if [ -f "$HOME/Library/DBeaverData/workspace6/.metadata/.plugins/org.jkiss.dbeaver.core/data-sources.json" ]; then
      echo "Backing up existing DBeaver configuration..."
      cp "$HOME/Library/DBeaverData/workspace6/.metadata/.plugins/org.jkiss.dbeaver.core/data-sources.json" \
         "$HOME/Library/DBeaverData/workspace6/.metadata/.plugins/org.jkiss.dbeaver.core/data-sources.json.backup"
    fi
    
    # Copy configuration from .dot-secrets
    if [ -f "$source_dir/dbeaver/data-sources.json" ]; then
      echo "Copying DBeaver configuration from .dot-secrets..."
      cp "$source_dir/dbeaver/data-sources.json" \
         "$HOME/Library/DBeaverData/workspace6/.metadata/.plugins/org.jkiss.dbeaver.core/data-sources.json"
      echo "DBeaver configuration has been applied."
    else
      echo "Warning: DBeaver configuration file not found in .dot-secrets."
      echo "Please check the template at $HOME/.dotfiles/templates/dot-secrets/dbeaver/data-sources.json"
      echo "and copy it to $source_dir/dbeaver/data-sources.json with your actual connections."
    fi
  else
    echo "DBeaver configuration directory not found. Please run DBeaver at least once to create it."
  fi
}

# Check if .dot-secrets exists instead of trying to set it up again
if [ -d "$HOME/.dot-secrets" ]; then
  configure_dbeaver "$HOME/.dot-secrets"
  echo "DBeaver configuration complete. You can open the application manually when needed."
else
  echo "Warning: .dot-secrets directory not found. Skipping DBeaver configuration."
  echo "Run 'script/bootstrap' to set up your .dot-secrets repository."
fi
