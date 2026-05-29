# Karabiner Elements

[Karabiner Elements](https://karabiner-elements.pqrs.org) keyboard remapping. The app is installed via the Brewfile cask.

## What `install.sh` does

Symlinks `karabiner/` to `~/.config/karabiner` (removes any existing symlink or directory first). Karabiner picks up changes to `karabiner.json` on the fly.

## Files

- `karabiner.json` — full configuration (rules, profiles, devices).
- `assets/` — supporting resources referenced by rules.
- `automatic_backups/` — gitignored snapshots Karabiner writes itself.
