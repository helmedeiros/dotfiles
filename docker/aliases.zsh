# shellcheck shell=bash
# Podman is a free, daemonless Docker Desktop replacement with a Docker-compatible
# CLI. `alias docker=podman` makes existing docker-style commands and the `d`
# alias below transparently drive podman (zsh re-expands aliases).
alias docker='podman'
alias d='docker'
# `dm` (docker swarm) has no podman equivalent — use `podman machine` / `podman pod`.
alias pm='podman machine'
