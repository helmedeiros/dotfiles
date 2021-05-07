#!/bin/sh
#
# Viscosity
set -e

cd "$(dirname "$0")/.."
DOTFILES_ROOT=$(pwd -P)

function preventing_network_leaks() {
  if [ -f /Library/Application\ Support/ViscosityScripts/disablenetwork.py ]
  then
    echo "  Viscosity was already configured."
  else
    echo "  Configuring viscosity network leak prevention."
    /Applications/Viscosity.app/Contents/MacOS/Viscosity -setSecureGlobalSetting YES -setting AllowOpenVPNScripts -value YES

    sudo mkdir -p "/Library/Application Support/ViscosityScripts"
    sudo cp $DOTFILES_ROOT/viscosity/disablenetwork.py "/Library/Application Support/ViscosityScripts"
    sudo chown -R root:wheel "/Library/Application Support/ViscosityScripts"
    sudo chmod -R 755 "/Library/Application Support/ViscosityScripts"
  fi
}

# Check for Viscosity
if [[ $(brew list --cask) =~ viscosity ]]
then
  preventing_network_leaks
fi
