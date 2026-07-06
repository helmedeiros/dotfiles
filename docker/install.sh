#!/bin/sh
#
# Podman needs a Linux VM ("machine") to run containers on macOS. Initialise it
# once, then make sure it's started. Safe to re-run: init is a no-op if the
# default machine already exists, and start is a no-op if it's already running.
if command -v podman >/dev/null 2>&1
then
  podman machine inspect podman-machine-default >/dev/null 2>&1 || podman machine init
  podman machine start 2>/dev/null || true
  podman --version
  podman compose version 2>/dev/null || true
fi
