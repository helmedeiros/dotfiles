# Homebrew

[Homebrew](https://brew.sh) bootstrap — installs `brew` itself on a fresh machine, and exposes its binaries on `PATH`.

## What `install.sh` does

If `brew` is missing, runs the official Homebrew installer over HTTPS. No-op if Homebrew is already on `PATH`.

## What `path.zsh` does

Prepends the Homebrew prefix (`/opt/homebrew/bin` on Apple Silicon, `/usr/local/bin` on Intel) and the GNU coreutils path to `PATH`.
