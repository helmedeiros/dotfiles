# Docker (Podman)

[Podman Desktop](https://podman-desktop.io) + the `podman` CLI, installed via the
Brewfile. This replaces Docker Desktop.

## Why Podman

- **Licensing** — Docker Desktop requires a paid subscription (Pro/Team/Business)
  for commercial use at organisations with 250+ employees or $10M+ annual
  revenue. Podman is free and open source with no such restriction.
- **Daemonless & rootless** — Podman runs containers without a background daemon
  or root privileges, which is lighter and reduces the attack surface.
- **Drop-in** — the CLI mirrors Docker's, so most commands work by swapping
  `docker` for `podman` (handled here by an alias). It also runs pods and
  Kubernetes YAML.

## What `install.sh` does

Initialises the Podman machine (the Linux VM that actually runs containers on
macOS) if it doesn't exist yet, starts it, then prints `podman --version` and
`podman compose version` as a sanity check. Safe to re-run.

## What gets loaded into your shell

- `aliases.zsh` — `alias docker=podman` (so existing docker commands just work),
  plus `d` and `pm` (`podman machine`) shortcuts.

## Migration notes

- Most workflows are unchanged: `podman` mirrors the Docker CLI.
- `docker compose` → `podman compose` (works via the alias).
- Migration guide: <https://developers.redhat.com/blog/2020/11/19/transitioning-from-docker-to-podman>
