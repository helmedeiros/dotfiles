#!/usr/bin/env bash
#
set -e

running_unattended () {
  [ -n "${CI:-}" ] || [ -n "${GITHUB_ACTIONS:-}" ] || [ ! -t 0 ]
}

setup_secret_dotfiles () {
  local -r dot_secret="$HOME/.dot-secrets"

  if [[ -d "${dot_secret}" || -L "${dot_secret}" ]]
  then
    return 0
  fi

  if running_unattended
  then
    info 'unattended run: refusing to clone .dot-secrets'
    return 0
  fi

  info 'setup dotfiles secrets'

  user ' - What is your github secrets repo URL?'
  read -e github_secrets_repo

  if ! git ls-remote "$github_secrets_repo" &>/dev/null; then
      fail "Unable to read from '$github_secrets_repo'"
  fi

  git clone "$github_secrets_repo" "$dot_secret"

  success 'Secrets Repo'
}
