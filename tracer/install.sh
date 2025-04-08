#!/usr/bin/env bash
#
# Tracer configuration and install.
set -e

# Source the path configuration
source "$(dirname "$0")/path.zsh"

setup () {
  echo "  Installing $1 for you."

  if [[ ! -d "$TRACER_HOME" ]]
  then
    git clone "$2" "$TRACER_HOME"
    cd "$TRACER_HOME"

    # Ensure Go is installed and GOPATH is set
    if ! command -v go &> /dev/null; then
      echo "  Go is not installed. Please install Go first."
      exit 1
    fi

    # Install development dependencies
    make dev-deps

    # Build and install using Makefile
    make install

    # Setup autocomplete using tracer's built-in command
    echo "  Setting up autocomplete..."
    tracer configure --autocomplete
  else
    echo "  $1 already installed. Updating..."
    cd "$TRACER_HOME"
    git pull
    make install
  fi
}

setup "tracer" "https://github.com/helmedeiros/tracer-bullet"
