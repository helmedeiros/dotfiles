#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

INSTALL_SH="${BATS_TEST_DIRNAME}/../../myke/install.sh"

setup() {
    TEST_ROOT="$(mktemp -d)"
    export HOME="${TEST_ROOT}/home"
    export DOT_SECRETS_ROOT="${TEST_ROOT}/secrets"
    mkdir -p "${HOME}" "${DOT_SECRETS_ROOT}/myke"

    # Source the install script as a library; the BASH_SOURCE guard
    # prevents setup_myke from auto-running on source.
    # shellcheck source=/dev/null
    source "${INSTALL_SH}"
}

teardown() {
    rm -rf "${TEST_ROOT}"
    unset MYKE_RELEASE_URL
}

# --- skip paths ---

@test "setup_myke skips when ~/.dot-secrets/myke/config.sh is absent" {
    run setup_myke
    [ "${status}" -eq 0 ]
    [[ "${output}" == *"~/.dot-secrets/myke/config.sh not present"* ]]
    [ ! -f "${HOME}/.myke/myke" ]
}

@test "setup_myke skips when MYKE_RELEASE_URL is empty in config" {
    cat > "${DOT_SECRETS_ROOT}/myke/config.sh" <<'EOF'
MYKE_RELEASE_URL=""
EOF

    run setup_myke
    [ "${status}" -eq 0 ]
    [[ "${output}" == *"MYKE_RELEASE_URL is unset"* ]]
    [ ! -f "${HOME}/.myke/myke" ]
}

@test "setup_myke does not redownload when binary is already in place" {
    mkdir -p "${HOME}/.myke"
    printf '#!/bin/sh\necho old\n' > "${HOME}/.myke/myke"
    chmod +x "${HOME}/.myke/myke"
    local before
    before=$(stat -f %m "${HOME}/.myke/myke")

    cat > "${DOT_SECRETS_ROOT}/myke/config.sh" <<EOF
MYKE_RELEASE_URL="file://${TEST_ROOT}/should-not-be-fetched"
EOF

    run setup_myke
    [ "${status}" -eq 0 ]
    [[ "${output}" == *"already installed"* ]]
    [ "$(stat -f %m "${HOME}/.myke/myke")" = "${before}" ]
}

# --- happy path with file:// ---

@test "setup_myke downloads binary from MYKE_RELEASE_URL when configured" {
    local fake_release="${TEST_ROOT}/release-myke"
    printf '#!/bin/sh\necho fake-myke\n' > "${fake_release}"

    cat > "${DOT_SECRETS_ROOT}/myke/config.sh" <<EOF
MYKE_RELEASE_URL="file://${fake_release}"
EOF

    run setup_myke
    [ "${status}" -eq 0 ]
    [ -x "${HOME}/.myke/myke" ]
    grep -q "fake-myke" "${HOME}/.myke/myke"
}
