# Slate

[Slate](https://github.com/jigish/slate) — older window manager (predecessor to the yabai setup). Installed via the Brewfile cask (`fertigt-slate`).

## What `install.sh` does

- Copies `.slate` (the configuration file) into `$HOME`.
- Opens `Slate.app` if not already running.
- Registers Slate as a macOS login item via AppleScript.

Functionally superseded by yabai + skhd in this dotfiles setup, but kept around for use on machines where yabai's SIP requirements aren't satisfied.
