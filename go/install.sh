#!/usr/bin/env bash
#
# go
#
# This installs go.
function installglobal() {
  echo " > go get ${@}"
  go get -u "${@}"
}

if test $(which go)
then
  echo "  Installing go and packages for you."

	mkdir -p $HOME/go

  installglobal golang.org/x/tools/cmd/goimports
  installglobal golang.org/x/tools/cmd/gorename
  installglobal github.com/sqs/goreturns
  installglobal github.com/nsf/gocode
  installglobal github.com/alecthomas/gometalinter
  installglobal github.com/zmb3/gogetdoc
  installglobal github.com/zmb3/goaddimport
  installglobal github.com/rogpeppe/godef
  installglobal github.com/gorilla/mux
  installglobal github.com/lib/pq
  installglobal github.com/spf13/cobra/cobra
fi
