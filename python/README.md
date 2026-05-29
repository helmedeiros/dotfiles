# Python

Python via [pyenv](https://github.com/pyenv/pyenv) for per-project version management.

## What `install.sh` does

- Installs `pyenv` via Homebrew if missing.
- Initialises pyenv for the install session (`eval "$(pyenv init -)"`).
- Installs the Python versions the dotfiles depend on (idempotent — `pyenv install -s`).

## What gets loaded into your shell

- `path.zsh` — wires pyenv shims into `PATH`.
- `aliases.zsh` — Python-specific aliases.
