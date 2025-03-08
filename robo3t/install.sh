#!/usr/bin/env bash
#
# Robo3T configuration and install.
source $(dirname $0)/../secrets/dots.sh

set -e

function configure_robo3t() {
  local source_dir="$1"
  local robo3t_version=$(ls -1 /Applications/Robo\ 3T.app/Contents/Info.plist 2>/dev/null | wc -l)
  
  if [ "$robo3t_version" -eq 0 ]; then
    echo "Robo 3T is not installed. Please install it first with 'brew install --cask robo-3t'."
    return 1
  fi
  
  # Check for Robo3T configuration directory
  local robo3t_dir="$HOME/.3T/robo-3t"
  
  if [ ! -d "$robo3t_dir" ]; then
    echo "Robo3T configuration directory not found. Please run Robo3T at least once to create it."
    return 1
  fi
  
  # Find the latest version directory
  local version_dir=$(find "$robo3t_dir" -type d -depth 1 | sort -r | head -n 1)
  
  if [ -z "$version_dir" ]; then
    echo "No Robo3T version directory found. Please run Robo3T at least once to create it."
    return 1
  fi
  
  echo "Found Robo3T configuration directory: $version_dir"
  
  # Backup existing configuration if it exists
  if [ -f "$version_dir/robo3t.json" ]; then
    echo "Backing up existing Robo3T configuration..."
    cp "$version_dir/robo3t.json" "$version_dir/robo3t.json.backup"
  fi
  
  # Copy configuration from .dot-secrets
  if [ -f "$source_dir/robo3t/robo3t.json" ]; then
    echo "Copying Robo3T configuration from .dot-secrets..."
    cp "$source_dir/robo3t/robo3t.json" "$version_dir/robo3t.json"
    echo "Robo3T configuration has been applied."
  else
    echo "Warning: Robo3T configuration file not found in .dot-secrets."
    echo "Please check the template at $HOME/.dotfiles/templates/dot-secrets/robo3t/robo3t.json"
    echo "and copy it to $source_dir/robo3t/robo3t.json with your actual connections."
  fi
}

# Check if .dot-secrets exists instead of trying to set it up again
if [ -d "$HOME/.dot-secrets" ]; then
  configure_robo3t "$HOME/.dot-secrets"
  echo "Robo3T configuration complete. You can open the application manually when needed."
else
  echo "Warning: .dot-secrets directory not found. Skipping Robo3T configuration."
  echo "Run 'script/bootstrap' to set up your .dot-secrets repository."
fi

# Removed automatic opening of Robo3T
# The application should be opened manually when needed, not during installation
