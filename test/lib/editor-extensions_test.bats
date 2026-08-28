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
    export TEST_DIR
    export ATTEMPTED_LOG="${TEST_DIR}/attempted"
    export UNAVAILABLE=""
    export TRANSIENT=""
    : > "${ATTEMPTED_LOG}"

    # No backoff in tests; the retry itself is what is under test.
    export EDITOR_EXTENSION_RETRY_DELAY=0

    CLI="${TEST_DIR}/editor-cli"
    cat > "${CLI}" <<'EOL'
#!/usr/bin/env bash
# Mimics `code --install-extension <id> --force`: writes the id it was asked
# for, fails permanently for the ids in $UNAVAILABLE, and fails once — the
# way a marketplace 503 does — for the ids in $TRANSIENT.
echo "$2" >> "${ATTEMPTED_LOG}"
case " ${UNAVAILABLE} " in
    *" $2 "*) echo "Extension '$2' not found." >&2; exit 1 ;;
esac
case " ${TRANSIENT} " in
    *" $2 "*)
        if [ ! -f "${TEST_DIR}/tried-$2" ]; then
            : > "${TEST_DIR}/tried-$2"
            echo "Error while installing extensions: Server returned 503" >&2
            exit 1
        fi
        ;;
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

@test "retries an extension the marketplace refuses once" {
    export TRANSIENT="first.extension"

    run install_editor_extensions "${CLI}" "${LIST}" "TestEditor"

    [ "${status}" -eq 0 ]
    [ "$(grep -cxF 'first.extension' "${ATTEMPTED_LOG}")" -eq 2 ]
}

@test "gives up on an extension that never installs" {
    export UNAVAILABLE="missing.extension"

    run install_editor_extensions "${CLI}" "${LIST}" "TestEditor"

    [ "${status}" -ne 0 ]
    [ "$(grep -cxF 'missing.extension' "${ATTEMPTED_LOG}")" -eq 3 ]
}
