#!/usr/bin/env bash
#
# Robo-3t configuration and install.
source $(dirname $0)/../secrets/dots.sh

set -e

function move_robo3t_connections_from() {
  mv ~/.3T/robo-3t/1.1.1/robo3t.json  ~/.3T/robo-3t/1.1.1/robo3t.json.original
  cp $1/robo3t/robo3t.json ~/.3T/robo-3t/1.1.1/robo3t.json
}

if test ! $(pgrep -f "Robo\ 3T")
then
  open "/Applications/Robo 3T.app"
fi

setup_secret_dotfiles;

move_robo3t_connections_from "$HOME/.dot-secrets";
