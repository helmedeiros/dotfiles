#!/usr/bin/env bats
#
# End-to-end checks on the two editor topics: settings land in the editor's
# user directory, the whole extension list is attempted even when the
# registry is missing an id, and an unavailable id is reported rather than
# silently swallowing every extension after it.
#
# Both scripts drive a stub editor CLI: vscode/install.sh finds `code` on
# PATH, cursor/install.sh reads its app bundle from $CURSOR_APP.

bats_require_minimum_version 1.5.0

DOTFILES="${BATS_TEST_DIRNAME}/../.."
VSCODE_SH="${DOTFILES}/vscode/install.sh"
CURSOR_SH="${DOTFILES}/cursor/install.sh"

make_stub_cli() {
    local path="$1"
    mkdir -p "$(dirname "$path")"
    cat > "$path" <<'EOL'
#!/usr/bin/env bash
echo "$2" >> "${ATTEMPTED_LOG}"
case " ${UNAVAILABLE} " in
    *" $2 "*) echo "Extension '$2' not found." >&2; exit 1 ;;
esac
EOL
    chmod +x "$path"
}

extension_ids() {
    grep -vE '^[[:space:]]*(#|$)' "$1"
}

setup() {
    TEST_DIR="$(mktemp -d)"
    export HOME="${TEST_DIR}/home"
    mkdir -p "${HOME}"

    export ATTEMPTED_LOG="${TEST_DIR}/attempted"
    export UNAVAILABLE=""
    : > "${ATTEMPTED_LOG}"

    make_stub_cli "${TEST_DIR}/bin/code"
    export PATH="${TEST_DIR}/bin:${PATH}"

    export CURSOR_APP="${TEST_DIR}/Cursor.app"
    make_stub_cli "${CURSOR_APP}/Contents/Resources/app/bin/cursor"
}

teardown() {
    rm -rf "${TEST_DIR}"
}

# --- VSCode ---

@test "vscode installs its settings" {
    run bash "${VSCODE_SH}"

    [ "${status}" -eq 0 ]
    [ -f "${HOME}/Library/Application Support/Code/User/settings.json" ]
    diff "${DOTFILES}/vscode/settings.json" \
        "${HOME}/Library/Application Support/Code/User/settings.json"
}

@test "vscode attempts every extension in its list" {
    run bash "${VSCODE_SH}"

    [ "${status}" -eq 0 ]
    expected=$(extension_ids "${DOTFILES}/vscode/extensions.txt" | wc -l)
    attempted=$(wc -l < "${ATTEMPTED_LOG}")
    [ "${attempted}" -eq "${expected}" ]
}

@test "vscode keeps installing after an id the marketplace does not carry" {
    UNAVAILABLE="$(extension_ids "${DOTFILES}/vscode/extensions.txt" | head -1)"
    export UNAVAILABLE
    last="$(extension_ids "${DOTFILES}/vscode/extensions.txt" | tail -1)"

    run bash "${VSCODE_SH}"

    [ "${status}" -ne 0 ]
    [[ "${output}" == *"${UNAVAILABLE}"* ]]
    grep -qxF "${last}" "${ATTEMPTED_LOG}"
}

# --- Cursor ---

@test "cursor installs its settings" {
    run bash "${CURSOR_SH}"

    [ "${status}" -eq 0 ]
    [ -f "${HOME}/Library/Application Support/Cursor/User/settings.json" ]
    diff "${DOTFILES}/cursor/settings.json" \
        "${HOME}/Library/Application Support/Cursor/User/settings.json"
}

@test "cursor and vscode do not install each other's settings" {
    run bash "${CURSOR_SH}"

    [ "${status}" -eq 0 ]
    run diff "${DOTFILES}/vscode/settings.json" \
        "${HOME}/Library/Application Support/Cursor/User/settings.json"
    [ "${status}" -ne 0 ]
}

@test "cursor attempts every extension in its list" {
    run bash "${CURSOR_SH}"

    [ "${status}" -eq 0 ]
    expected=$(extension_ids "${DOTFILES}/cursor/extensions.txt" | wc -l)
    attempted=$(wc -l < "${ATTEMPTED_LOG}")
    [ "${attempted}" -eq "${expected}" ]
}

@test "cursor keeps installing after an id its registry does not carry" {
    UNAVAILABLE="$(extension_ids "${DOTFILES}/cursor/extensions.txt" | head -1)"
    export UNAVAILABLE
    last="$(extension_ids "${DOTFILES}/cursor/extensions.txt" | tail -1)"

    run bash "${CURSOR_SH}"

    [ "${status}" -ne 0 ]
    [[ "${output}" == *"${UNAVAILABLE}"* ]]
    grep -qxF "${last}" "${ATTEMPTED_LOG}"
}

@test "cursor skips without failing when Cursor is not installed" {
    export CURSOR_APP="${TEST_DIR}/absent.app"

    run bash "${CURSOR_SH}"

    [ "${status}" -eq 0 ]
    [[ "${output}" == *"not installed"* ]]
}
