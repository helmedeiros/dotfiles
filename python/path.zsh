#!/bin/zsh
#
# Python and pyenv configuration
# Uses lazy loading to avoid slow shell startup (~0.2s savings)
#

if command -v pyenv &> /dev/null; then
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/shims:$PATH"

  # Lazy-load full pyenv init only when pyenv is called directly
  pyenv() {
    unset -f pyenv
    eval "$(command pyenv init -)"
    if command -v pyenv-virtualenv-init &> /dev/null; then
      eval "$(command pyenv virtualenv-init -)"
    fi
    pyenv "$@"
  }
fi
