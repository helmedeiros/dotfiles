# myke

[myke](https://github.com/omio-labs/myke) — Make-like task runner used at Omio. Not in Homebrew, so installed by hand.

## What `install.sh` does

Downloads the `darwin_${arch}` myke binary for v1.0.2 from GitHub Releases into `~/.myke/myke` (picks `arm64` vs `amd64` from `uname -m`). Idempotent — skips if `~/.myke` already exists.

## What gets loaded into your shell

- `path.zsh` — prepends `~/.myke` to `PATH`.
