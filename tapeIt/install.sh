#!/usr/bin/env bash
#
# tapeit — install/update the tapeit CLI.
#
# tapeit is a Go binary; `go install` drops it in $GOPATH/bin, which
# go/path.zsh already puts on PATH, so no path.zsh is needed here.
set -e

if ! command -v go &> /dev/null; then
  echo "  Go is not installed, skipping."
  echo "  It ships in the Brewfile — 'brew install go' — then re-run this."
  exit 0
fi

echo "  Installing tapeit for you."
go install github.com/helmedeiros/tapeit/cmd/tapeit@latest
