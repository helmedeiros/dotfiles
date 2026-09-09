# Keyboard Text Replacements Template

macOS keyboard text substitutions (System Settings > Keyboard > Text
Replacements, `NSUserDictionaryReplacementItems`) are personal shorthand —
often full snippets of text — so the real data lives in `.dot-secrets`, not
in the public dotfiles repo.

## Usage

The easiest way to populate this is to snapshot what's already configured
on your Mac, rather than hand-writing the plist:

```bash
~/.dotfiles/keyboard/export.sh
```

This reads `NSUserDictionaryReplacementItems` from `NSGlobalDomain` and
writes it to `~/.dot-secrets/keyboard/text-replacements.plist`.

To restore it (e.g. on a new machine, or after editing System Settings and
re-exporting):

```bash
~/.dotfiles/keyboard/install.sh
```

`bin/dot` runs `keyboard/install.sh` automatically on every run, so once
the file exists in `.dot-secrets`, new machines pick it up for free.

## Template Structure

`text-replacements.plist.example` shows the expected shape: a plist
containing a single key, `NSUserDictionaryReplacementItems`, whose value is
an array of `{ on, replace, with }` dicts. Replace the sample entry — or
just run `export.sh` instead of hand-editing this.

## Notes

- `defaults import` merges by key, so importing only touches
  `NSUserDictionaryReplacementItems` — the rest of `NSGlobalDomain` is left
  alone.
- Re-run `export.sh` any time you add/edit replacements in System Settings,
  then commit the updated file in `.dot-secrets`.
