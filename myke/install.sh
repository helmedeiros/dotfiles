#!/usr/bin/env bash
#
# Hoster configuration and install.
set -e

setup_myke() {
  echo "  Installing myke for you."

  local -r dot_myke="$HOME/.myke"

  if [[ ! -d "$dot_myke" ]]
  then
    mkdir -p $dot_myke
    wget -qO $dot_myke/myke https://github.com/omio-labs/myke/releases/download/v1.0.2/myke_darwin_amd64
    chmod +x $dot_myke/myke
  else
    echo "  myke already installed."
  fi

}


setup_myke
