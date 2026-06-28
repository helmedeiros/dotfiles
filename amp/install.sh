#!/usr/bin/env bash
#
# amp (Apple Music Player) — install/update the `am` CLI and its zsh completion.
#
# `am` is a Go binary; `go install` drops it in $GOPATH/bin, which go/path.zsh
# already puts on PATH, so no path.zsh is needed here. The completion is a
# static dispatcher written into this topic dir, which zsh/fpath.zsh adds to
# fpath, so new shells tab-complete `am` automatically.
set -e

if ! command -v go &> /dev/null; then
  echo "  Go is not installed. Please install Go first."
  exit 1
fi

echo "  Installing am (amp) for you."
go install github.com/helmedeiros/amp/cmd/am@latest

# Locate the just-installed binary without relying on PATH during install.
gobin="$(go env GOBIN)"
[ -z "$gobin" ] && gobin="$(go env GOPATH)/bin"

echo "  Refreshing zsh completion."
"$gobin/am" completion zsh > "$(dirname "$0")/_am"
