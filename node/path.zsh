#!/bin/zsh
#
# Node.js and NVM configuration
# Uses lazy loading to avoid slow shell startup (~2.4s savings)
#

# Set NVM directory
export NVM_DIR="$HOME/.nvm"

# Add the latest installed node version to PATH immediately (no NVM overhead)
# This makes node/npm available instantly without loading NVM
if [ -d "$NVM_DIR/versions/node" ]; then
  _nvm_latest=$(ls -d "$NVM_DIR/versions/node/"v* 2>/dev/null | sort -V | tail -1)
  if [ -n "$_nvm_latest" ] && [ -d "$_nvm_latest/bin" ]; then
    export PATH="$_nvm_latest/bin:$PATH"
  fi
  unset _nvm_latest
fi

# Lazy-load NVM: only source nvm.sh when nvm is first called
_load_nvm() {
  unset -f nvm node npm npx
  if [ -s "$NVM_DIR/nvm.sh" ]; then
    source "$NVM_DIR/nvm.sh" > /dev/null 2>&1
  fi
  if [ -s "$NVM_DIR/bash_completion" ]; then
    source "$NVM_DIR/bash_completion" > /dev/null 2>&1
  fi
}

nvm() { _load_nvm && nvm "$@"; }
node() { _load_nvm && node "$@"; }
npm() { _load_nvm && npm "$@"; }
npx() { _load_nvm && npx "$@"; }
