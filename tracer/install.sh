#!/usr/bin/env bash
#
# tracer — install/update the tracer CLI and its zsh completion.
#
# tracer is a Go binary; `go install` drops it in $GOPATH/bin, which
# go/path.zsh already puts on PATH, so no path.zsh is needed here. The
# completion is a static dispatcher written into this topic dir, which
# zsh/fpath.zsh adds to fpath, so new shells tab-complete `tracer`.
set -e

if ! command -v go &> /dev/null; then
  echo "  Go is not installed. Please install Go first."
  exit 1
fi

echo "  Installing tracer for you."
go install github.com/helmedeiros/tracer-bullet/cmd/tracer@latest

# Locate the just-installed binary without relying on PATH during install.
gobin="$(go env GOBIN)"
[ -z "$gobin" ] && gobin="$(go env GOPATH)/bin"

echo "  Refreshing zsh completion."
"$gobin/tracer" completion zsh > "$(dirname "$0")/_tracer"
