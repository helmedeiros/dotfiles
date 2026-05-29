#!/usr/bin/env bash
#
# Helper functions for claude/install.sh. Kept separate so individual functions
# can be sourced and tested in isolation without executing the full installer.

# Idempotently symlink a source file to a destination.
#
# - If the destination is already a symlink to the source: no-op.
# - If the destination is a symlink pointing elsewhere: back up to .bak.<timestamp>.
# - If the destination is a real file or directory: back up to .bak.<timestamp>.
# - Creates parent directories as needed.
#
# Args:
#   $1 - absolute source path (must exist)
#   $2 - absolute destination path
link_claude_file() {
    local src="$1"
    local dst="$2"

    if [ -z "$src" ] || [ -z "$dst" ]; then
        echo "link_claude_file: src and dst are required" >&2
        return 2
    fi

    if [ ! -e "$src" ]; then
        echo "link_claude_file: source not found: $src" >&2
        return 1
    fi

    mkdir -p "$(dirname "$dst")"

    if [ -L "$dst" ]; then
        local current
        current="$(readlink "$dst")"
        if [ "$current" = "$src" ]; then
            return 0
        fi
        mv "$dst" "${dst}.bak.$(date +%s)"
    elif [ -e "$dst" ]; then
        mv "$dst" "${dst}.bak.$(date +%s)"
    fi

    ln -s "$src" "$dst"
}
