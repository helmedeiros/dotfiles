# yabai

[yabai](https://github.com/koekeishiya/yabai) — tiling window manager for macOS. Installed via the Brewfile from `koekeishiya/formulae`.

## What `install.sh` does

- Symlinks `yabai/` to `~/.config/yabai` (removes any existing symlink or directory first).
- Starts the yabai service via `yabai --start-service` if installed and not already running.

## Configuration

- `yabairc` — the yabai config, loaded automatically on service start.
