# yabai

[yabai](https://github.com/asmvik/yabai) — tiling window manager for macOS. Installed via the Brewfile from `asmvik/formulae` (the tap moved when its author renamed the account from `koekeishiya`).

## What `install.sh` does

- Symlinks `yabai/` to `~/.config/yabai` (removes any existing symlink or directory first).
- Starts the yabai service via `yabai --start-service` if installed and not already running.

## Configuration

- `yabairc` — the yabai config, loaded automatically on service start.
