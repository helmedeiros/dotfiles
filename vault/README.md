# HashiCorp Vault

[Vault](https://www.vaultproject.io/) CLI, pinned to a known version. No longer available in Homebrew core (entry removed from Brewfile), so installed by hand.

## What `install.sh` does

Downloads the official Vault zip from `releases.hashicorp.com` for the pinned `VAULT_VERSION` (currently `1.13.1`), picks `amd64` vs `arm64` from `uname -m`, and drops the binary on `PATH`. Skips if the installed version already matches.

## What gets loaded into your shell

- `path.zsh` — ensures the install directory is on `PATH`.
