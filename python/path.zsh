#!/bin/zsh
#
# Python and pyenv configuration
#

# Initialize pyenv if available
if command -v pyenv &> /dev/null; then
  # Set up pyenv root directory
  export PYENV_ROOT="$HOME/.pyenv"

  # Initialize pyenv - this sets up shims and completions
  eval "$(pyenv init -)"

  # Enable pyenv virtualenv if available
  if command -v pyenv-virtualenv-init &> /dev/null; then
    eval "$(pyenv virtualenv-init -)"
  fi
fi
