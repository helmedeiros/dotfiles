#!/usr/bin/env bash
#
# go
#
# This installs go.
function installglobal() {
  go get -u "${@}" 2> /dev/null
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
fi
