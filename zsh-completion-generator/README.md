# zsh-completion-generator

Auto-generated zsh completion files for CLI tools that don't ship their own. Uses [RobSis/zsh-completion-generator](https://github.com/RobSis/zsh-completion-generator) under the hood.

## What `install.sh` does

- Clones (or `git pull`s) `zsh-completion-generator` into `~/.zsh-completion-generator`.
- Runs `generate.sh` under zsh, which calls the plugin's `gencomp` function for each tool listed in the script and writes a `_<tool>` completion file into this directory.

## What gets loaded into your shell

- `path.zsh` — prepends this directory to `fpath` so zsh picks up the generated completions on startup.

## Files

- `_*` — generated completion files (committed so they're available immediately on a fresh machine, before `bin/dot` regenerates them).
- `err_*` — captured stderr from failed completion runs (kept for debugging).
- `generate.sh` — the per-tool list and `gencomp` invocations.

## Tests

BATS coverage lives in `test/zsh-completion-generator/` and the related per-tool fixtures in `test/mothers/gencomp_mother.sh`.
