#!/bin/sh
#
# Viscosity
set -e

cd "$(dirname "$0")/.." || exit 1
DOTFILES_ROOT=$(pwd -P)

VISCOSITY_APP="${VISCOSITY_APP:-/Applications/Viscosity.app}"
VISCOSITY_SCRIPTS="${VISCOSITY_SCRIPTS:-/Library/Application Support/ViscosityScripts}"

preventing_network_leaks() {
  if [ -f "$VISCOSITY_SCRIPTS/disablenetwork.py" ]
  then
    echo "  Viscosity was already configured."
  else
    echo "  Configuring viscosity network leak prevention."
    # Try to set the secure global setting, but don't fail if it doesn't work
    # This may require Viscosity to be running or have specific permissions
    "$VISCOSITY_APP/Contents/MacOS/Viscosity" -setSecureGlobalSetting YES -setting AllowOpenVPNScripts -value YES 2>/dev/null || {
      echo "  Warning: Could not set Viscosity secure global setting (may need to configure manually in Viscosity preferences)"
    }

    sudo mkdir -p "$VISCOSITY_SCRIPTS"
    sudo cp "$DOTFILES_ROOT/viscosity/disablenetwork.py" "$VISCOSITY_SCRIPTS"
    sudo chown -R root:wheel "$VISCOSITY_SCRIPTS"
    sudo chmod -R 755 "$VISCOSITY_SCRIPTS"
  fi
}

if brew list --cask 2>/dev/null | grep -q viscosity
then
  preventing_network_leaks
fi
