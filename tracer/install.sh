#!/usr/bin/env bash
#
# Tracer configuration and install.
set -e

setup () {
  echo "  Installing $1 for you."

  local -r dot_path="$HOME/.$1"

  if [[ ! -d "$dot_path" ]]
  then
    git clone "$2" "$dot_path"
    chmod +x "$dot_path"/$1

    tracer configure --autocomplete
  else
    echo "  $1 already installed."
  fi
}

setup "tracer" "https://github.com/helmedeiros/tracer-bullet"
