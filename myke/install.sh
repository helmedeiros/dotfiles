#!/usr/bin/env bash
#
# Hoster configuration and install.
set -e

setup_myke() {
  echo "  Installing myke for you."

  local -r dot_myke="$HOME/.myke"

  if [[ ! -d "$dot_myke" ]]
  then
    mkdir -p "$dot_myke"
    local arch
    arch=$(uname -m)
    if [[ "$arch" == "arm64" ]]; then
      arch="arm64"
    else
      arch="amd64"
    fi
    curl -fsSL -o "$dot_myke/myke" "https://github.com/omio-labs/myke/releases/download/v1.0.2/myke_darwin_${arch}"
    chmod +x "$dot_myke/myke"
  else
    echo "  myke already installed."
  fi

}


setup_myke
