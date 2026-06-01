#!/usr/bin/env bash
#
# integrity.sh
#
# Helpers for downloading external binaries / scripts with SHA-256 checksum
# verification. Used by topic install scripts that fetch from the network
# (currently node/install.sh for the nvm installer and myke/install.sh for
# the myke binary).
#
# Pinning by checksum — not just version — defends against three failure
# modes: a hijacked upstream account, a compromised CDN, and an
# in-the-middle network attack on a fresh-machine install.

# Verify a file matches an expected SHA-256.
# Args:
#   $1 - file path
#   $2 - expected SHA-256 (lowercase hex)
#   $3 - optional friendly name for diagnostics (default: file path)
verify_sha256() {
    local file="$1"
    local expected="$2"
    local friendly="${3:-$1}"

    if [ -z "$file" ] || [ -z "$expected" ]; then
        echo "verify_sha256: file and expected sha are required" >&2
        return 2
    fi

    if [ ! -f "$file" ]; then
        echo "verify_sha256: file not found: $file" >&2
        return 1
    fi

    local actual
    actual=$(shasum -a 256 "$file" | awk '{print $1}')

    if [ "$actual" != "$expected" ]; then
        echo "Error: SHA-256 mismatch for ${friendly}" >&2
        echo "  expected: ${expected}" >&2
        echo "  actual:   ${actual}" >&2
        return 1
    fi
    return 0
}

# Download a URL to a tempfile and verify its SHA-256 in one step. The
# verified path is echoed to stdout — the caller is responsible for moving
# it to the final destination and cleaning up the tempfile if it stays
# put.
#
# Args:
#   $1 - URL (anything 'curl -fsSL' accepts, including file://)
#   $2 - expected SHA-256
#   $3 - optional friendly name for diagnostics (default: "download")
download_verified() {
    local url="$1"
    local expected="$2"
    local friendly="${3:-download}"

    if [ -z "$url" ] || [ -z "$expected" ]; then
        echo "download_verified: url and expected sha are required" >&2
        return 2
    fi

    local tmp
    tmp=$(mktemp)

    if ! curl -fsSL -o "$tmp" "$url"; then
        rm -f "$tmp"
        echo "Error: failed to download ${friendly} from ${url}" >&2
        return 1
    fi

    if ! verify_sha256 "$tmp" "$expected" "$friendly"; then
        rm -f "$tmp"
        return 1
    fi

    echo "$tmp"
}
