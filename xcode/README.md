# xcode

[Xcode](https://developer.apple.com/xcode/) — Apple's IDE, and the source of the full toolchain (`xcodebuild`, platform SDKs, Simulator) that the Command Line Tools alone do not provide.

Needed here for anything that builds a real macOS/iOS app from source — for example the maintained [`mokagio/vimac`](https://github.com/mokagio/vimac) fork noted in [`../vimac/README.md`](../vimac/README.md), which ships no prebuilt binary.

## How it gets installed

Two halves, both driven by `bin/dot`:

| Step | Owner | What it does |
| --- | --- | --- |
| Install the app | `Brewfile` (`mas 'Xcode', id: 497799835`) | `brew bundle` installs it from the Mac App Store |
| Activate the toolchain | `install.sh` | selects the developer dir, accepts the license, runs first-launch |

It is **not fully unattended**, for two reasons that are Apple's, not this repo's:

1. Xcode is ~15 GB into `/Applications`, and `mas` shells out to `sudo` to write it — a fresh install prompts for your password. Run `bin/dot` from a terminal where you can type it.
2. `mas` can only install apps already associated with the signed-in Apple ID. On a brand-new Apple ID it fails until you "Get" Xcode once from the App Store GUI. Same constraint the [`amphetamine`](../amphetamine/) topic documents.

If `brew bundle` cannot install it, `install.sh` prints the manual route rather than pretending to have succeeded:

```sh
open "macappstores://apps.apple.com/app/id497799835"
sudo mas install 497799835
```

## What `install.sh` does

Runs after `brew bundle`, and is idempotent — every step is guarded by a check, so re-runs are no-ops:

- Exits `0` with instructions if `Xcode.app` is absent, so a machine that does not want Xcode is never blocked.
- `xcode-select -s` onto `Xcode.app/Contents/Developer` if the active directory is still `/Library/Developer/CommandLineTools`. Without this, `xcodebuild` fails with *"tool 'xcodebuild' requires Xcode"* even with Xcode installed.
- `xcodebuild -license accept` if the license has not been accepted yet.
- `xcodebuild -runFirstLaunch` to install the bundled platform SDKs.

The three privileged steps go through a `run_privileged` helper that refuses to block on a password prompt when nothing is attached to stdin, so a non-interactive `bin/dot` degrades to a printed instruction instead of hanging forever.

## Configuration

- `aliases.zsh` — `ios` opens the iOS Simulator bundled inside `Xcode.app`.

## Verifying

```sh
xcode-select -p          # → /Applications/Xcode.app/Contents/Developer
xcodebuild -version      # → Xcode <version>
```
