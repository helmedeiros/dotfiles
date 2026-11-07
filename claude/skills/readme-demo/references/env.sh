# shellcheck shell=bash
DEMO_HOME="$(mktemp -d)"
export DEMO_HOME
export HOME="$DEMO_HOME"
export PATH="$PWD/bin:$PATH"
export PS1='$ '
cd "$DEMO_HOME" || return
