# shellcheck shell=bash
#
# Base PATH. Relative ./bin is kept LAST so installed/system commands win
# over a repo's local build; in-repo dev builds are run explicitly
# (./bin/tool, go run). MANPATH for the common non-standard tool locations.
export PATH="$HOME/.local/bin:/usr/local/bin:/usr/local/sbin:$ZSH/bin:$PATH:./bin"
export MANPATH="/usr/local/man:/usr/local/mysql/man:/usr/local/git/man:$MANPATH"
