# Raycast

[Raycast](https://raycast.com) — Spotlight replacement. Installed via the Brewfile cask.

## What `install.sh` does

If `Raycast.app` is installed and `com.raycast.macos.plist` exists in this directory, imports the plist via `defaults import com.raycast.macos`. No-op if Raycast isn't installed yet.

## Capturing settings

Run `raycast/export.sh` to snapshot your current Raycast preferences into `com.raycast.macos.plist` — useful before machine setup so the new install matches the old one.
