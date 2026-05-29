# Caffeine

[Caffeine](https://www.caffeine-app.net) — keeps your Mac awake. Installed via the Brewfile cask.

## What `install.sh` does

If the Caffeine cask is installed, sends `tell application "Caffeine" to turn on` via osascript so caffeination is active immediately. Idempotent.
