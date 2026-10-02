#!/bin/sh
#
# Podman needs a Linux VM ("machine") to run containers on macOS. Initialise it
# once, then make sure it's started. Safe to re-run: init is a no-op if the
# default machine already exists, and start is a no-op if it's already running.
if command -v podman >/dev/null 2>&1
then
  # `machine init`/`start` print informational banners (rootless mode notes,
  # the mac-helper suggestion, DOCKER_HOST export instructions) that aren't
  # actionable here — aliases.zsh already derives DOCKER_HOST itself. Capture
  # the output and only surface it if the command actually fails.
  if ! podman machine inspect podman-machine-default >/dev/null 2>&1; then
    init_out=$(podman machine init 2>&1) || printf '%s\n' "$init_out" >&2
  fi
  if ! start_out=$(podman machine start 2>&1); then
    # "already running" is the expected no-op case on a re-run, not a failure.
    printf '%s\n' "$start_out" | grep -qi 'already running' \
      || printf '%s\n' "$start_out" >&2
  fi
  podman --version
  podman compose version 2>/dev/null || true
fi
