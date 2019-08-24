#!/usr/bin/env bash
#
# Robo-3t configuration and install.
source $(dirname $0)/../secrets/dots.sh

set -e

function move_robo3t_connections_from() {
  local -r robo3t="~/.3T"

  if [[ -d "${robo3t}" || -L "${robo3t}" ]]; then
    if [ -f ~/.3T/robo-3t/1.2.1/robo3t.json ]; then
      mv ~/.3T/robo-3t/1.2.1/robo3t.json  ~/.3T/robo-3t/1.2.1/robo3t.json.original
    fi

    cp $1/robo3t/robo3t.json ~/.3T/robo-3t/1.2.1/robo3t.json
  fi
}

if test ! $(pgrep -f "Robo\ 3T")
then
  open "/Applications/Robo 3T.app"
fi

setup_secret_dotfiles;

move_robo3t_connections_from "$HOME/.dot-secrets";
