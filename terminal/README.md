# Terminal

Theme bootstrap for `Terminal.app` and `iTerm2`.

## What `install.sh` does

- Sets `Terminal.app`'s default string encoding to UTF-8 (`defaults write com.apple.terminal StringEncodings`).
- If the `Solarized Dark xterm-256color` theme isn't already registered, opens the bundled `.terminal` file via AppleScript and promotes it to the default. Idempotent.

## Bundled themes

- `Solarized Dark xterm-256color.terminal` — for `Terminal.app`.
- `Solarized Dark.itermcolors` — for iTerm2 (import manually via Preferences → Profiles → Colors).
