# hoster

[hoster](https://github.com/helmedeiros/hoster) — small CLI for managing `/etc/hosts` entries by group.

## What `install.sh` does

Clones the hoster repository to `~/.hoster` if absent, and ensures the `hoster` binary is executable. Idempotent.

## What gets loaded into your shell

- `path.zsh` — prepends `~/.hoster` to `PATH` so the binary is reachable.
