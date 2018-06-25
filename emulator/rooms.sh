#!/usr/bin/env bash
#
set -e

setup_rooms () {
  local -r rooms="$HOME/.rooms"

  if ! [[ -d "${rooms}" || -L "${rooms}" ]]; then
    info 'setup rooms'

    user ' - What is your github rooms repo URL?'
    read -e github_rooms_repo

    git ls-remote "$github_rooms_repo" &>-
    if [ "$?" -ne 0 ]; then
      fail "Unable to read from '$github_rooms_repo'"
    fi

    git clone "$github_rooms_repo" "$rooms"

    success 'Rooms Repo'
  fi
}
