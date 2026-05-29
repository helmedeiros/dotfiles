# macOS

System-level macOS configuration. No-op on non-Darwin platforms.

## What `install.sh` does

Runs `sudo softwareupdate -i -a` to pull and install pending macOS system updates.

## What `set-defaults.sh` does

A long list of `defaults write` calls that tune Finder, Dock, trackpad, keyboard, screenshots, screen capture, etc. Called from `bin/dot` near the start of the install run. Tested via `test/bin/macos_defaults_test.bats`.
