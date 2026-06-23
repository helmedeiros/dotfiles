# Amphetamine

[Amphetamine](https://apps.apple.com/us/app/amphetamine/id937984704) — keeps your Mac awake. Replaces the old Caffeine cask with a more capable, free Mac App Store app (timed sessions, app/display/battery triggers, full AppleScript support).

## Install

Amphetamine is **Mac App Store-only** — there is no Homebrew cask. It is installed through the `mas` entry in the [Brewfile](../Brewfile):

```ruby
mas 'Amphetamine', id: 937984704
```

`brew bundle` installs it during `dot`. Caveat: `mas` can only install apps already associated with your Apple ID. On a brand-new machine, open the App Store once and **Get** Amphetamine (search, or [App Store link](https://apps.apple.com/us/app/amphetamine/id937984704)); afterwards `mas` reinstalls it unattended on any machine.

## What `install.sh` does

If Amphetamine is installed (checked via `mas list`), it starts an indefinite keep-awake session immediately with:

```applescript
tell application "Amphetamine" to start new session
```

If the app isn't present yet, it prints a hint and exits cleanly so a fresh-machine `dot` run never fails. Idempotent — starting a session while one is active is a no-op.

For timed sessions you can pass options, e.g.:

```applescript
tell application "Amphetamine" to start new session with options {duration:8, interval:hours, displaySleepAllowed:false}
```
