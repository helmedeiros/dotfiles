#!/usr/bin/env bash
#
# editor-extensions.sh
#
# Shared installer for VS Code / Cursor extension lists.
#
# Both topics inlined the same loop, and fe31bbc had to fix the same
# abort-on-first-failure bug in each of them separately — the sign that the
# loop wants one home. VS Code and Cursor pull from different registries, so
# an id one of them is missing is a normal event, not a reason to abandon
# the other sixty.
#
# No arrays or other bash 4 constructs: this is sourced by topic install.sh
# files, and macOS still ships bash 3.2 as /bin/bash.

# Install every extension listed in a file through an editor CLI.
# Args:
#   $1 - editor CLI (path or command name)
#   $2 - extensions list file: one id per line, # comments and blanks ignored
#   $3 - friendly editor name used in messages (default: the CLI's basename)
# Returns 0 when every extension installed, 1 otherwise.
install_editor_extensions() {
    local cli="$1"
    local list="$2"
    local label="${3:-$(basename "$cli")}"

    if [ ! -f "$list" ]; then
        echo "${label} extensions list not found: ${list}" >&2
        return 1
    fi

    local failed_list=""
    local failed_count=0
    local extension

    # `|| [ -n "$extension" ]`: a last line with no trailing newline is still
    # an extension.
    while IFS= read -r extension || [ -n "$extension" ]; do
        case "$extension" in
            ''|'#'*) continue ;;
        esac

        echo "Installing extension: ${extension}"
        if ! "$cli" --install-extension "$extension" --force; then
            failed_list="${failed_list}  - ${extension}
"
            failed_count=$((failed_count + 1))
        fi
    done < "$list"

    if [ "$failed_count" -eq 0 ]; then
        echo "All ${label} extensions installed."
        return 0
    fi

    echo "${failed_count} ${label} extension(s) could not be installed:" >&2
    printf '%s' "$failed_list" >&2
    return 1
}
