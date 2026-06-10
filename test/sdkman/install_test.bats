#!/usr/bin/env bats
#
# Exercises the SHA-pinned SDKMAN installer path without hitting the
# network and without invoking the real bootstrap (which would create
# ~/.sdkman). Mirrors test/node/installNVM_test.bats — see that file's
# header for the rationale.

bats_require_minimum_version 1.5.0

DOTFILES="${BATS_TEST_DIRNAME}/../.."
INSTALL_SH="${DOTFILES}/sdkman/install.sh"

setup() {
    TEST_HOME="$(mktemp -d)"
    export HOME="${TEST_HOME}"

    # shellcheck source=/dev/null
    source "${DOTFILES}/lib/integrity.sh"

    SDKMAN_INSTALLER_SHA256=$(grep '^SDKMAN_INSTALLER_SHA256=' "${INSTALL_SH}" | sed 's/.*"\(.*\)"/\1/')
}

teardown() {
    rm -rf "${TEST_HOME}"
}

# --- Static guards on the install script itself ---

@test "sdkman/install.sh pins SDKMAN_INSTALLER_URL to get.sdkman.io" {
    grep -qE '^SDKMAN_INSTALLER_URL="https://get\.sdkman\.io/' "${INSTALL_SH}"
}

@test "sdkman/install.sh pins SDKMAN_INSTALLER_SHA256 to a 64-hex-char value" {
    grep -qE '^SDKMAN_INSTALLER_SHA256="[0-9a-f]{64}"$' "${INSTALL_SH}"
}

@test "sdkman/install.sh sources lib/integrity.sh" {
    grep -q 'lib/integrity.sh' "${INSTALL_SH}"
}

@test "sdkman/install.sh uses download_verified, not unverified curl|bash" {
    grep -q 'download_verified' "${INSTALL_SH}"
    # The 'curl ... | bash' pattern must be gone from executable code.
    # Strip comments first so any rationale text doesn't trip the check.
    ! grep -vE '^[[:space:]]*#' "${INSTALL_SH}" | grep -qE 'curl[^|]*\| *bash'
}

@test "sdkman/install.sh passes rcupdate=false so SDKMAN won't rewrite zshrc" {
    grep -q 'rcupdate=false' "${INSTALL_SH}"
}

# --- Functional: SHA gate honours match and mismatch ---

@test "download_verified accepts a fixture matching its own SHA" {
    local fixture="${TEST_HOME}/installer"
    printf 'fake-sdkman-installer-payload\n' > "${fixture}"
    local sha
    sha=$(shasum -a 256 "${fixture}" | awk '{print $1}')

    run download_verified "file://${fixture}" "${sha}" "test installer"
    [ "${status}" -eq 0 ]
    [ -f "${output}" ]
    grep -q 'fake-sdkman-installer-payload' "${output}"
}

@test "download_verified refuses to return the file when SHA mismatches" {
    local fixture="${TEST_HOME}/installer"
    printf 'tampered-payload\n' > "${fixture}"

    run download_verified "file://${fixture}" "${SDKMAN_INSTALLER_SHA256}" "SDKMAN installer"
    [ "${status}" -ne 0 ]
    [[ "${output}" == *"SHA-256 mismatch for SDKMAN installer"* ]]
}
