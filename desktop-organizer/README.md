# Desktop Organizer

Keeps `~/Desktop` clean automatically by moving settled items into Dropbox. A
launchd agent watches the Desktop and runs a small classifier — so screenshots
file themselves and stray files land in a single inbox instead of piling up.

## What it does

| Item on the Desktop | Where it goes |
| --- | --- |
| Screenshots & screen recordings (`Screenshot …`, `Screen Recording …`, `CleanShot …`, `SCR-…`) | `~/Dropbox/Screenshots/<year>/` — year parsed from the filename, falling back to the file's modification year |
| Everything else (files and, by default, folders) | `~/Dropbox/Desktop-Inbox/` |

`Desktop-Inbox/` is a **staging area, not a permanent home**. Full automation
never guesses a final category (employment vs. work vs. personal) — that stays a
deliberate choice. File things out of the inbox with the `catalog-document`
skill when you want them properly placed under `~/Dropbox/DOCUMENTS/`.

### Safety properties

- **Never deletes.** Only moves.
- **Grace period** (`GRACE_MINUTES`, default 2): items you just created or are
  actively dragging are left alone; a later timer pass sweeps them.
- **No overwrites.** Name collisions get ` 2`, ` 3`, … appended.
- **Ignores** `.DS_Store`, `.localized`, the Finder `Icon` file, and all
  dotfiles.
- Does nothing if Dropbox isn't mounted at `~/Dropbox`.

## How `install.sh` does

Renders `com.helmedeiros.desktop-organizer.plist.template` with this machine's
absolute paths into `~/Library/LaunchAgents/`, then (re)loads it with
`launchctl`. Run automatically by `bin/dot`; idempotent, safe to re-run.

The agent triggers on any change to `~/Desktop` (`WatchPaths`) and also on a
5-minute timer (`StartInterval`) so grace-period items eventually get swept.

## Full Disk Access (required for the background agent)

macOS protects `~/Desktop`, `~/Documents`, and `~/Downloads` behind TCC. A
launchd agent cannot read the Desktop until it is granted **Full Disk Access** —
without it the log fills with `find: …/Desktop: Operation not permitted`.

To keep the grant narrow, the agent does not run `/bin/sh` directly (granting
FDA to `/bin/sh` would hand full access to *every* shell script on the machine).
Instead `install.sh` compiles a tiny single-purpose helper,
`desktop-organizer-runner`, whose only ability is to launch this script. Full
Disk Access is granted to that binary alone. See [`runner.c`](runner.c) for why
it spawns the script as a child rather than exec-ing into it.

Grant it once:

1. **System Settings → Privacy & Security → Full Disk Access**
2. Click **+**, press **⌘⇧G**, and add
   `~/.dotfiles/desktop-organizer/desktop-organizer-runner`.
3. Toggle it **on**, then reload the agent:
   `launchctl kickstart -k "gui/$(id -u)/com.helmedeiros.desktop-organizer"`

Because the helper is ad-hoc signed, **recompiling it invalidates the grant**.
`install.sh` only rebuilds when `runner.c` changes, so normal `bin/dot` runs keep
the grant valid; if you edit `runner.c` you'll need to re-add it.

Running the script by hand from a terminal that already has disk access does
**not** need this grant — only the unattended agent does.

## Manual use

```sh
desktop-organizer/desktop-organizer.sh --dry-run   # preview, move nothing
desktop-organizer/desktop-organizer.sh             # sweep now
```

Logs go to `~/Library/Logs/desktop-organizer.log`.

## Configuration

Edit the config block at the top of [`desktop-organizer.sh`](desktop-organizer.sh):

- `INBOX_NAME` — the catch-all folder name under Dropbox
- `GRACE_MINUTES` — how long a file must sit before it's eligible to move
- `MOVE_DIRECTORIES` — set to `false` to leave folders on the Desktop
- `IGNORE_GLOBS` — basenames never to touch
- the `classify()` function — add rules here to route specific filename
  patterns to their own destinations

## Uninstall

```sh
launchctl bootout "gui/$(id -u)/com.helmedeiros.desktop-organizer"
rm ~/Library/LaunchAgents/com.helmedeiros.desktop-organizer.plist
```
