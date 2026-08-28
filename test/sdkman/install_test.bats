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
    run ! bash -c "grep -vE '^[[:space:]]*#' '${INSTALL_SH}' | grep -qE 'curl[^|]*\| *bash'"
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

# --- Functional: the run survives SDKMAN's own nounset-unsafe code ---

# The real `sdk` function dereferences $PAGER (src/sdkman-utils.sh) with no
# default. An unbound variable is fatal for a non-interactive bash even inside
# an `if` condition, so with nounset on, the installer died at the first
# `sdk list java` — silently, because that call redirects stderr to /dev/null.
# Java (installed before the regression) stayed; gradle, maven and groovy were
# never installed and enableGradleDaemon never ran.
fake_sdkman_init() {
    mkdir -p "${HOME}/.sdkman/bin"
    cat > "${HOME}/.sdkman/bin/sdkman-init.sh" <<'EOL'
sdk() {
    : "$PAGER"  # mirrors the real SDKMAN's unguarded expansion
    case "$1" in
        current) echo "Using java version 21-tem" ;;
    esac
    return 0
}
EOL
}

@test "the run completes when SDKMAN's own code is not nounset-safe" {
    unset PAGER
    fake_sdkman_init

    run bash "${INSTALL_SH}"

    [ "${status}" -eq 0 ]
    [[ "${output}" == *"SDKMAN setup complete"* ]]
}

@test "the run reaches enableGradleDaemon" {
    unset PAGER
    fake_sdkman_init

    run bash "${INSTALL_SH}"

    grep -q '^org.gradle.daemon=true$' "${HOME}/.gradle/gradle.properties"
}

# A stub `sdk` that reports nothing installed and installs successfully
# without reading stdin — exactly like the real one once it has decided it
# has nothing to ask.
fake_sdkman_init_fresh() {
    mkdir -p "${HOME}/.sdkman/bin"
    cat > "${HOME}/.sdkman/bin/sdkman-init.sh" <<'EOL'
sdk() {
    : "$PAGER"
    [ "$1" = "current" ] && return 1
    return 0
}
EOL
}

@test "a successful install is not reported as a failure" {
    unset PAGER
    fake_sdkman_init_fresh

    run bash "${INSTALL_SH}"

    [ "${status}" -eq 0 ]
    [[ "${output}" != *"Warning: failed to install"* ]]
}

@test "a candidate installed but not default is left alone" {
    unset PAGER
    fake_sdkman_init_fresh
    mkdir -p "${HOME}/.sdkman/candidates/java/21-tem"

    run bash "${INSTALL_SH}"

    [ "${status}" -eq 0 ]
    [[ "${output}" == *"java 21-tem already installed, skipping"* ]]
    [[ "${output}" != *"Installing java"* ]]
}
