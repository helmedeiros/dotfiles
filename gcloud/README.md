# Google Cloud SDK

[Google Cloud SDK](https://cloud.google.com/sdk) (`gcloud-cli`) is installed via the Brewfile as a cask.

## What `install.sh` does

Currently a stub (`set -e` only). The cask install handles the binaries and shell-completion files; everything else (authentication, project selection) is per-machine and stays out of dotfiles.

## What gets loaded into your shell

- `completion.zsh` — sources the gcloud-provided zsh completion functions.
