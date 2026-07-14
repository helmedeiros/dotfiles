# shellcheck shell=bash
# Podman is a free, daemonless Docker Desktop replacement with a Docker-compatible
# CLI. `alias docker=podman` makes existing docker-style commands and the `d`
# alias below transparently drive podman (zsh re-expands aliases).
alias docker='podman'
alias d='docker'
# `dm` (docker swarm) has no podman equivalent — use `podman machine` / `podman pod`.
alias pm='podman machine'

# Docker-API clients (Testcontainers, docker SDKs, IDE plugins) look for a socket
# at the default path, which podman doesn't create without the sudo mac-helper.
# Point DOCKER_HOST at podman's own socket instead — derived at shell start so it
# survives temp-path changes. ~10ms; silent no-op if podman/machine is absent.
if command -v podman >/dev/null 2>&1; then
  __podman_sock="$(podman machine inspect --format '{{.ConnectionInfo.PodmanSocket.Path}}' 2>/dev/null)"
  [ -n "$__podman_sock" ] && export DOCKER_HOST="unix://$__podman_sock"
  unset __podman_sock
fi
