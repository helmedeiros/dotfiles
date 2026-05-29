#!/usr/bin/env bash
#
# git-identity.sh
#
# Render git/gitconfig.symlink from the example template, pulling the
# author name + email from ~/.dot-secrets/git/identity.sh when available
# so neither value lives in the public dotfiles repo.

# shellcheck source=dot-secrets.sh
. "$(dirname "${BASH_SOURCE[0]}")/dot-secrets.sh"

# Render a gitconfig from a template by substituting placeholders.
# Uses '|' as sed delimiter so name/email containing '/' (rare but legal)
# don't break the substitution.
#
# Args:
#   $1 - source template path (e.g. git/gitconfig.symlink.example)
#   $2 - output path
#   $3 - author name
#   $4 - author email
#   $5 - credential helper (osxkeychain on darwin, cache otherwise)
render_gitconfig() {
    local template="$1"
    local output="$2"
    local name="$3"
    local email="$4"
    local helper="$5"

    if [ ! -f "$template" ]; then
        echo "render_gitconfig: template not found: $template" >&2
        return 1
    fi

    sed -e "s|AUTHORNAME|${name}|g" \
        -e "s|AUTHOREMAIL|${email}|g" \
        -e "s|GIT_CREDENTIAL_HELPER|${helper}|g" \
        "$template" > "$output"
}

# Try to populate GIT_AUTHOR_NAME and GIT_AUTHOR_EMAIL from .dot-secrets.
# Returns 0 if both values are non-empty after sourcing, 1 otherwise.
load_git_identity_from_secrets() {
    # Reset to detect whether values came from the secrets file.
    GIT_AUTHOR_NAME=""
    GIT_AUTHOR_EMAIL=""

    if ! source_dot_secret "git/identity.sh"; then
        return 1
    fi

    [ -n "${GIT_AUTHOR_NAME}" ] && [ -n "${GIT_AUTHOR_EMAIL}" ]
}

# Default credential helper based on platform.
default_credential_helper() {
    if [ "$(uname -s)" = "Darwin" ]; then
        echo "osxkeychain"
    else
        echo "cache"
    fi
}
