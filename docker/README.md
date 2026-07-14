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
  plus `d` and `pm` (`podman machine`) shortcuts. It also exports `DOCKER_HOST`
  (see below).

## Docker API socket

Podman starts a clean machine but does **not** create a socket at Docker's
conventional `/var/run/docker.sock`, so it prints a notice on start:

> The system helper service is not installed; the default Docker API socket
> address can't be used by podman.

The `podman`/`docker` CLI is unaffected. Only clients that talk to the Docker
**API socket** directly (Testcontainers, docker SDKs, IDE Docker plugins) need a
socket to point at. `aliases.zsh` handles this for your shell by exporting
`DOCKER_HOST` to podman's own socket path.

That covers shells that source these dotfiles. If you also need **GUI apps**
launched from Finder (e.g. a JetBrains IDE) to reach Docker, install the mac
helper once — it creates the global `/var/run/docker.sock` symlink (needs sudo,
so it's a manual step, not part of `install.sh`):

```sh
sudo "$(brew --prefix podman)/bin/podman-mac-helper" install
podman machine stop && podman machine start
```

## Migration notes

- Most workflows are unchanged: `podman` mirrors the Docker CLI.
- `docker compose` → `podman compose` (works via the alias).
- Migration guide: <https://developers.redhat.com/blog/2020/11/19/transitioning-from-docker-to-podman>
