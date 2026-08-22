# skhd

[skhd](https://github.com/asmvik/skhd) — hotkey daemon driving yabai keybindings. Installed via the Brewfile from `asmvik/formulae` (the tap moved when its author renamed the account from `koekeishiya`).

## What `install.sh` does

- Symlinks `skhd/` to `~/.config/skhd` (removes any existing symlink or directory first).
- Starts the skhd service via `skhd --start-service` if installed and not already running.

## Configuration

- `skhdrc` — hotkey definitions; reloaded automatically by skhd on save.
