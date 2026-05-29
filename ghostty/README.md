# Ghostty

[Ghostty](https://ghostty.org) terminal configuration. Ghostty itself is installed via the Brewfile.

## What `install.sh` does

Symlinks the entire `ghostty/` directory of this repo to `~/.config/ghostty`. If a real config directory or stale symlink already exists, it's removed first — there's no backup step, so don't run this if you have unmerged local edits in `~/.config/ghostty`.
