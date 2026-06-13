# macOS

System-level macOS configuration. No-op on non-Darwin platforms.

## What `install.sh` does

Runs `sudo softwareupdate -i -a` to pull and install pending macOS system updates.

## What `set-defaults.sh` does

A long list of `defaults write` calls that tune Finder, Dock, trackpad, keyboard, screenshots, screen capture, etc. Called from `bin/dot` near the start of the install run. Tested via `test/bin/macos_defaults_test.bats`.

At the end it invokes `bind-filetypes.sh` to apply per-app file-type bindings.

## File-type bindings (`bind-filetypes.sh`)

Each app folder may declare which file extensions it wants to own by dropping a `filetypes` file in its directory. `bind-filetypes.sh` discovers all of them, reads each one's `APP` and `EXTENSIONS`, and calls `duti` to set the LaunchServices binding.

Format (see `templates/filetypes.example`):

```bash
APP="Cursor.app"            # resolved against /Applications/$APP
EXTENSIONS=(
  md markdown json yaml sh py go ts tsx
)
```

Behavior:

- Apps whose `.app` isn't installed are silently skipped. Removing a cask from the `Brewfile` and uninstalling the app cleanly disables its bindings on the next run.
- Removing a folder's `filetypes` file stops new bindings from being applied, but **existing** LaunchServices entries persist until another app claims the same UTI or you run `lsregister -kill -r -domain local -domain system -domain user` and re-bind.
- When two folders claim the same extension, the last alphabetical glob wins. Document overlaps in the relevant folder's README.
- Requires `duti` (in `Brewfile`).
