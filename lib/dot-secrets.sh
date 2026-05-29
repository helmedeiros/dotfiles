#!/usr/bin/env bash
#
# dot-secrets.sh
#
# Helper for sourcing per-topic configuration from the private ~/.dot-secrets
# repository. Employer-specific values, internal hostnames, personal identity,
# and company-tool URLs live there, not in this public repo.

# Root of the .dot-secrets repo (override DOT_SECRETS_ROOT for tests).
: "${DOT_SECRETS_ROOT:=$HOME/.dot-secrets}"

# Source a file inside ~/.dot-secrets relative to its root.
#
# Args:
#   $1 - path within .dot-secrets, e.g. "kubernetes/config.sh"
#
# Returns 0 if the file was sourced, 1 if missing. Silent on missing — callers
# decide whether to warn or fail, because some topics are optional (e.g.
# kubernetes config) and others are required (e.g. myke release URL).
source_dot_secret() {
    local rel_path="$1"
    if [ -z "$rel_path" ]; then
        echo "source_dot_secret: relative path is required" >&2
        return 2
    fi

    local full_path="$DOT_SECRETS_ROOT/$rel_path"
    if [ -f "$full_path" ]; then
        # shellcheck disable=SC1090
        . "$full_path"
        return 0
    fi
    return 1
}

# Require a .dot-secrets file or fail loudly with a pointer at the template.
# Args:
#   $1 - relative path inside .dot-secrets
#   $2 - relative path inside templates/dot-secrets/ for the diagnostic message
require_dot_secret() {
    local rel_path="$1"
    local template_hint="$2"

    if source_dot_secret "$rel_path"; then
        return 0
    fi

    echo "Error: required .dot-secrets file not found: $DOT_SECRETS_ROOT/$rel_path" >&2
    if [ -n "$template_hint" ]; then
        echo "       template: $template_hint" >&2
    fi
    echo "       see the .dot-secrets README in your private repo for layout details." >&2
    return 1
}
