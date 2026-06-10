# shellcheck shell=bash
#
# Go: GOPATH + bin on PATH.
#
# The previous version called `go env GOPATH` twice on every shell open,
# which forked the go binary just to print "$HOME/go" — go 1.8+ defaults
# GOPATH to $HOME/go when unset, so the subprocess was always returning
# the constant we could have set ourselves. Using ${GOPATH:-$HOME/go}
# preserves any override the user sets in ~/.localrc or via env without
# spawning go on every prompt.

export GOPATH="${GOPATH:-$HOME/go}"
export PATH="$PATH:$GOPATH/bin"
