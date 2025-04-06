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
    cd "$dot_path"
    go mod tidy
    go install
    chmod +x "$(go env GOPATH)/bin/$1"

    tracer configure --autocomplete
  else
    echo "  $1 already installed. Updating..."
    cd "$dot_path"
    git pull
    go mod tidy
    go install
  fi
}

setup "tracer" "https://github.com/helmedeiros/tracer-bullet"
