#!/usr/bin/env bash
#
set -e

. "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/unattended.sh"

setup_rooms () {
  local -r rooms="$HOME/.rooms"

  if [[ -d "${rooms}" || -L "${rooms}" ]]; then
    return 0
  fi

  if running_unattended; then
    info 'unattended run: refusing to clone the rooms repo'
    return 0
  fi

  info 'setup rooms'

  user ' - What is your github rooms repo URL?'
  read -e github_rooms_repo

  if ! git ls-remote "$github_rooms_repo" &>/dev/null; then
    fail "Unable to read from '$github_rooms_repo'"
  fi

  git clone "$github_rooms_repo" "$rooms"

  success 'Rooms Repo'
}
