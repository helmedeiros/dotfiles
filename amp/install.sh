#!/usr/bin/env bash
#
# amp (Apple Music Player) — install/update the `amp` CLI, the `amd` daemon,
# and the zsh completion.
#
# Both are Go binaries; `go install` drops them in $GOPATH/bin, which
# go/path.zsh already puts on PATH, so no path.zsh is needed here. The
# completion is a static dispatcher written into this topic dir, which
# zsh/fpath.zsh adds to fpath, so new shells tab-complete `amp` automatically.
set -e

if ! command -v go &> /dev/null; then
  echo "  Go is not installed. Please install Go first."
  exit 1
fi

echo "  Installing amp and amd for you."
go install github.com/helmedeiros/amp/cmd/amp@latest
go install github.com/helmedeiros/amp/cmd/amd@latest

# Locate the just-installed binary without relying on PATH during install.
gobin="$(go env GOBIN)"
[ -z "$gobin" ] && gobin="$(go env GOPATH)/bin"

echo "  Refreshing zsh completion."
"$gobin/amp" completion zsh > "$(dirname "$0")/_amp"
