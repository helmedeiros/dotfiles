#!/usr/bin/env bash
#
# Robo3T configuration and install.
#
# Every path out of here that is not "config copied" is a *skip*: a machine
# without Robo 3T, or one that has never launched it, has nothing to
# configure. Returning non-zero for those made script/install list robo3t
# among the failed installers on every run of a machine that simply does not
# use Robo 3T.
#
# secrets/dots.sh used to be sourced here; it only defines
# setup_secret_dotfiles, which this script never calls — script/bootstrap owns
# cloning ~/.dot-secrets.

set -e

# Overridable so both the installed and the not-installed branch are
# reachable in tests without a real /Applications/Robo 3T.app.
ROBO3T_APP="${ROBO3T_APP:-/Applications/Robo 3T.app}"

# Newest ~/.3T/robo-3t/<version> directory, or nothing if Robo 3T has never
# been launched. -mindepth/-maxdepth rather than BSD-only `-depth 1`.
function robo3t_version_dir() {
  local robo3t_dir="$HOME/.3T/robo-3t"

  [ -d "$robo3t_dir" ] || return 0
  find "$robo3t_dir" -mindepth 1 -maxdepth 1 -type d | sort -r | head -n 1
}

function configure_robo3t() {
  local source_dir="$1"
  local version_dir="$2"
  local config="$source_dir/robo3t/robo3t.json"

  if [ ! -f "$config" ]; then
    echo "Warning: Robo3T configuration file not found in .dot-secrets."
    echo "Please check the template at $HOME/.dotfiles/templates/dot-secrets/robo3t/robo3t.json"
    echo "and copy it to $config with your actual connections."
    return 0
  fi

  if [ -f "$version_dir/robo3t.json" ]; then
    echo "Backing up existing Robo3T configuration..."
    cp "$version_dir/robo3t.json" "$version_dir/robo3t.json.backup"
  fi

  echo "Copying Robo3T configuration from .dot-secrets..."
  cp "$config" "$version_dir/robo3t.json"
  echo "Robo3T configuration has been applied."
}

# --- run ---

if [ ! -d "$ROBO3T_APP" ]; then
  echo "Robo 3T is not installed, skipping configuration."
  echo "Install it with 'brew install --cask robo-3t'."
  exit 0
fi

version_dir="$(robo3t_version_dir)"
if [ -z "$version_dir" ]; then
  echo "No Robo3T configuration directory found, skipping configuration."
  echo "Please run Robo 3T at least once to create it."
  exit 0
fi
echo "Found Robo3T configuration directory: $version_dir"

if [ ! -d "$HOME/.dot-secrets" ]; then
  echo "Warning: .dot-secrets directory not found. Skipping Robo3T configuration."
  echo "Run 'script/bootstrap' to set up your .dot-secrets repository."
  exit 0
fi

configure_robo3t "$HOME/.dot-secrets" "$version_dir"
echo "Robo3T configuration complete. You can open the application manually when needed."
