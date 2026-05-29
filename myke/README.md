# myke

[myke](https://github.com/omio-labs/myke) — Make-like task runner shipped as a single binary outside Homebrew. The specific release URL is per-employer / per-team config and lives in `~/.dot-secrets/myke/config.sh`, not in this public repo.

## What `install.sh` does

- If `~/.myke/myke` is already in place, no-op.
- Sources `~/.dot-secrets/myke/config.sh` (see [`templates/dot-secrets/myke/`](../templates/dot-secrets/myke/) for the shape). If the file is missing or `MYKE_RELEASE_URL` is empty, install.sh skips with a clear message — myke is optional, so a fresh machine without `.dot-secrets` is fine.
- Otherwise downloads `${MYKE_RELEASE_URL}` into `~/.myke/myke` and marks it executable.

## What gets loaded into your shell

- `path.zsh` — exports `MYKE_HOME` and prepends `~/.myke/` to `PATH`.
