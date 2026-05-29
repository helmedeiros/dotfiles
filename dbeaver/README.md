# DBeaver

[DBeaver Community Edition](https://dbeaver.io) database client. Installed via the Brewfile cask (`dbeaver-community`).

## What `install.sh` does

Restores DBeaver's data sources (and other config) from `~/.dot-secrets/dbeaver/` into `~/Library/DBeaverData/workspace6/`, backing up any existing config first. Errors out if DBeaver itself isn't installed.

Connection settings live in `.dot-secrets` (private repo) rather than this public dotfiles repo since they often contain hostnames and credentials.
