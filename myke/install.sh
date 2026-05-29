#!/usr/bin/env bash
#
# myke installer. The release URL is per-employer / per-team config and
# lives in ~/.dot-secrets/myke/config.sh, not in this public repo.
#
# When the .dot-secrets file is absent (or MYKE_RELEASE_URL is empty) the
# script is a no-op — myke is optional and a fresh machine without
# .dot-secrets shouldn't fail bin/dot just because of it.

set -e

# shellcheck source=../lib/dot-secrets.sh
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/dot-secrets.sh"

setup_myke() {
    local -r dot_myke="$HOME/.myke"

    if [ -d "$dot_myke" ] && [ -x "$dot_myke/myke" ]; then
        echo "  myke already installed."
        return 0
    fi

    if ! source_dot_secret "myke/config.sh"; then
        echo "  myke skipped: ~/.dot-secrets/myke/config.sh not present."
        echo "  (see templates/dot-secrets/myke/config.sh.example for the shape.)"
        return 0
    fi

    if [ -z "${MYKE_RELEASE_URL:-}" ]; then
        echo "  myke skipped: MYKE_RELEASE_URL is unset in .dot-secrets/myke/config.sh."
        return 0
    fi

    echo "  Installing myke from ${MYKE_RELEASE_URL}"
    mkdir -p "$dot_myke"
    curl -fsSL -o "$dot_myke/myke" "$MYKE_RELEASE_URL"
    chmod +x "$dot_myke/myke"
}

if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    setup_myke
fi
