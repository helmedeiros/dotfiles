# tmux

[tmux](https://github.com/tmux/tmux) configuration plus [TPM](https://github.com/tmux-plugins/tpm) plugin manager.

## What `install.sh` does

Clones TPM into `~/.tmux/plugins/tpm` if absent. No-op otherwise. tmux itself is installed via the Brewfile.

## What gets loaded into your shell

- `aliases.zsh` — tmux session shortcuts.
- `tmux.conf.symlink` — symlinked to `~/.tmux.conf` by `script/bootstrap`. Loads TPM and configures keybindings, status line, etc.
