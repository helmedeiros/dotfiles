# Go

Go toolchain configuration and supporting CLI tooling.

## What `install.sh` does

- Verifies `go` is on `PATH` (installed via Brewfile).
- Creates `$HOME/go` if missing.
- `go install`s a handful of helper binaries at `@latest`: `goimports`, `gorename`, `gocode`, `gogetdoc`, `godef`, `cobra-cli`.

## What `path.zsh` does

Exports `GOPATH` / `GOBIN` and prepends `$GOPATH/bin` to `PATH` so installed binaries are reachable.
