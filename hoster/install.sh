#!/usr/bin/env bash
#
# Hoster configuration and install.
set -e

setup_hoster () {
  echo "  Installing hoster for you."

  local -r dot_hoster="$HOME/.hoster"

  if [[ ! -d "$dot_hoster" ]]
  then
    git clone https://github.com/helmedeiros/hoster "$dot_hoster"
    chmod +x ~/.hoster/hoster
  else
    echo "  hoster already installed."
  fi
}

setup_hoster
