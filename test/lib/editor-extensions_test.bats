#!/usr/bin/env bats
#
# One unavailable extension must not cost the rest of the list. VS Code and
# Cursor draw from different registries, so an id one of them does not carry
# is a normal event — and with `set -e` and a bare install call it used to
# abort the loop, silently leaving every later extension uninstalled.

bats_require_minimum_version 1.5.0

DOTFILES="${BATS_TEST_DIRNAME}/../.."

setup() {
    TEST_DIR="$(mktemp -d)"
    export ATTEMPTED_LOG="${TEST_DIR}/attempted"
    export UNAVAILABLE=""
    : > "${ATTEMPTED_LOG}"

    CLI="${TEST_DIR}/editor-cli"
    cat > "${CLI}" <<'EOL'
#!/usr/bin/env bash
# Mimics `code --install-extension <id> --force`: writes the id it was asked
# for, and fails for the ids named in $UNAVAILABLE.
echo "$2" >> "${ATTEMPTED_LOG}"
case " ${UNAVAILABLE} " in
    *" $2 "*) echo "Extension '$2' not found." >&2; exit 1 ;;
esac
EOL
    chmod +x "${CLI}"

    LIST="${TEST_DIR}/extensions.txt"
    cat > "${LIST}" <<'EOL'
# Theme
first.extension

# Python
missing.extension
last.extension
EOL

    # shellcheck source=/dev/null
    source "${DOTFILES}/lib/editor-extensions.sh"
}

teardown() {
    rm -rf "${TEST_DIR}"
}

@test "installs every extension in the list" {
    run install_editor_extensions "${CLI}" "${LIST}" "TestEditor"

    [ "${status}" -eq 0 ]
    [ "$(wc -l < "${ATTEMPTED_LOG}" | tr -d ' ')" -eq 3 ]
}

@test "skips comments and blank lines" {
    run install_editor_extensions "${CLI}" "${LIST}" "TestEditor"

    run ! grep -q '^#' "${ATTEMPTED_LOG}"
    run ! grep -q '^$' "${ATTEMPTED_LOG}"
}

@test "keeps going after an extension the registry does not carry" {
    export UNAVAILABLE="missing.extension"

    run install_editor_extensions "${CLI}" "${LIST}" "TestEditor"

    grep -q '^last.extension$' "${ATTEMPTED_LOG}"
}

@test "reports the failures and exits non-zero" {
    export UNAVAILABLE="missing.extension"

    run install_editor_extensions "${CLI}" "${LIST}" "TestEditor"

    [ "${status}" -ne 0 ]
    [[ "${output}" == *"missing.extension"* ]]
    [[ "${output}" == *"TestEditor"* ]]
}

@test "does not report a failure when every extension installs" {
    run install_editor_extensions "${CLI}" "${LIST}" "TestEditor"

    [ "${status}" -eq 0 ]
    [[ "${output}" != *"could not be installed"* ]]
}

@test "fails when the list file is missing" {
    run install_editor_extensions "${CLI}" "${TEST_DIR}/nope.txt" "TestEditor"

    [ "${status}" -ne 0 ]
    [[ "${output}" == *"not found"* ]]
}

@test "handles a list whose last line has no trailing newline" {
    printf 'only.extension' > "${LIST}"

    run install_editor_extensions "${CLI}" "${LIST}" "TestEditor"

    [ "${status}" -eq 0 ]
    grep -q '^only.extension$' "${ATTEMPTED_LOG}"
}
