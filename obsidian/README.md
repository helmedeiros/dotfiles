# Obsidian

[Obsidian](https://obsidian.md) markdown knowledge base. The app is installed via the Brewfile (`cask 'obsidian'`).

## What `install.sh` does

Ensures the cask is installed, then seeds a vault's `.obsidian/` config from `vault-defaults/` so a fresh vault opens with graph view, backlinks, outline, and `[[wikilinks]]` enabled.

```sh
obsidian/install.sh [VAULT_DIR]     # defaults to $OBSIDIAN_VAULT or ~/second-brain
```

Config is copied (not symlinked) because Obsidian mutates `.obsidian/` at runtime; existing files are kept, so it never clobbers a configured vault.

## Vault defaults (`vault-defaults/`)

- `core-plugins.json` — graph, backlinks, outgoing links, outline, tag pane, quick switcher on
- `app.json` — wikilinks (not markdown links), shortest new-link format, auto-update links
- `appearance.json` — dark theme

## Personal knowledge graph

The primary vault is the PKG built from ChatGPT history at `~/second-brain` (nodes + generated MOCs). See that repo's pipeline for regeneration.
