#!/bin/sh
# Tmux Install Script
# Clones TPM (Tmux Plugin Manager) if not already present

TPM_DIR=$HOME/.tmux/plugins/tpm

printf "Installing tmux config.\n"

if [ ! -d "$TPM_DIR" ]; then
  printf "Cloning TPM (Tmux Plugin Manager).\n"
  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
else
  printf "TPM already installed.\n"
fi

printf "Tmux config installation complete.\n"
