#!/usr/bin/env bash
#
set -e

setup_secret_dotfiles () {
  local -r dot_secret="$HOME/.dot-secrets"

  if ! [[ -d "${dot_secret}" || -L "${dot_secret}" ]]
  then
    info 'setup dotfiles secrets'

    user ' - What is your github secrets repo URL?'
    read -e github_secrets_repo

    if ! git ls-remote "$github_secrets_repo" &>/dev/null; then
        fail "Unable to read from '$github_secrets_repo'"
    fi

    git clone "$github_secrets_repo" "$dot_secret"

    success 'Secrets Repo'

  fi
}
