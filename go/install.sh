#!/usr/bin/env bash
#
# go
#
# This installs go.
function installglobal() {
  echo " > go install ${@}@latest"
  go install "${@}@latest"
}

if test $(which go)
then
  echo "  Installing go and packages for you."

	mkdir -p $HOME/go

  installglobal golang.org/x/tools/cmd/goimports
  installglobal golang.org/x/tools/cmd/gorename
  installglobal github.com/nsf/gocode
  installglobal github.com/zmb3/gogetdoc
  installglobal github.com/rogpeppe/godef
  installglobal github.com/spf13/cobra-cli
fi
