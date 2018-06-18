#!/usr/bin/env bash
#
# go
#
# This installs go.

if test $(which go)
then
  echo "  Installing go for you."

	mkdir $HOME/go

  go get -u golang.org/x/tools/cmd/goimports
  go get -u golang.org/x/tools/cmd/gorename
  go get -u github.com/sqs/goreturns
  go get -u github.com/nsf/gocode
  go get -u github.com/alecthomas/gometalinter
  go get -u github.com/zmb3/gogetdoc
  go get -u github.com/zmb3/goaddimport
  go get -u github.com/rogpeppe/godef
fi
