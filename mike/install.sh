#!/usr/bin/env bash
#
# Hoster configuration and install.
set -e

setup_mike() {
  echo "  Installing mike for you."

  local -r dot_mike="$HOME/.mike"

  if [[ ! -d "$dot_mike" ]]
  then
    mkdir -p $dot_mike
    wget -qO $dot_mike/mike https://github.com/goeuro/myke/releases/download/v1.0.0/myke_darwin_amd64
    chmod +x $dot_mike/mike
  else
    echo "  mike already installed."
  fi

}


setup_mike
