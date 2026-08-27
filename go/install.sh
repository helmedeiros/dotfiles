#!/usr/bin/env bash
#
# go
#
# This installs go.
# One package per call. "${@}@latest" appended @latest to the first argument
# only and passed the rest bare, so a multi-argument call would have installed
# whatever version those resolved to.
installglobal() {
  echo " > go install ${1}@latest"
  go install "${1}@latest"
}

if command -v go > /dev/null 2>&1
then
  echo "  Installing go and packages for you."

	mkdir -p "$HOME/go"

  installglobal golang.org/x/tools/cmd/goimports
  installglobal golang.org/x/tools/cmd/gorename
  installglobal github.com/nsf/gocode
  installglobal github.com/zmb3/gogetdoc
  installglobal github.com/rogpeppe/godef
  installglobal github.com/spf13/cobra-cli
fi
