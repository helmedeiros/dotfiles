# Node.js / npm

Node.js via [nvm](https://github.com/nvm-sh/nvm) plus a curated set of global npm packages.

## What `install.sh` does

- Installs nvm (v0.39.7) into `~/.nvm` if absent.
- Installs the latest LTS Node.js via nvm.
- `npm install -g`s a curated set of global packages, tolerating individual install failures.

## What gets loaded into your shell

- `path.zsh` — sources `nvm.sh` and configures the nvm environment without auto-use (so it doesn't switch versions on every `cd`).
- `npmrc.symlink` — symlinked to `~/.npmrc` by `script/bootstrap`.
