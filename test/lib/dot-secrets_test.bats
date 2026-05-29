#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

LIB_SH="${BATS_TEST_DIRNAME}/../../lib/dot-secrets.sh"

setup() {
    TEST_HOME="$(mktemp -d)"
    export DOT_SECRETS_ROOT="${TEST_HOME}/.dot-secrets"
    mkdir -p "${DOT_SECRETS_ROOT}"
    # shellcheck source=/dev/null
    source "${LIB_SH}"
}

teardown() {
    rm -rf "${TEST_HOME}"
}

# --- source_dot_secret ---

@test "source_dot_secret returns 0 and applies values when file exists" {
    mkdir -p "${DOT_SECRETS_ROOT}/git"
    echo 'TEST_VALUE="from-secret"' > "${DOT_SECRETS_ROOT}/git/identity.sh"

    source_dot_secret "git/identity.sh"
    [ "${TEST_VALUE}" = "from-secret" ]
}

@test "source_dot_secret returns 1 when file is missing" {
    run source_dot_secret "absent/file.sh"
    [ "${status}" -eq 1 ]
}

@test "source_dot_secret fails on missing argument" {
    run source_dot_secret ""
    [ "${status}" -eq 2 ]
}

@test "source_dot_secret honours DOT_SECRETS_ROOT override" {
    local alt="${TEST_HOME}/alt-secrets"
    mkdir -p "${alt}/myke"
    echo 'ALT_VALUE="overridden"' > "${alt}/myke/config.sh"

    DOT_SECRETS_ROOT="${alt}" source_dot_secret "myke/config.sh"
    [ "${ALT_VALUE}" = "overridden" ]
}

# --- require_dot_secret ---

@test "require_dot_secret applies values when present (mirrors source_dot_secret)" {
    mkdir -p "${DOT_SECRETS_ROOT}/myke"
    echo 'MYKE_URL="https://example.test/myke"' > "${DOT_SECRETS_ROOT}/myke/config.sh"

    require_dot_secret "myke/config.sh"
    [ "${MYKE_URL}" = "https://example.test/myke" ]
}

@test "require_dot_secret exits non-zero and prints diagnostic when file missing" {
    run require_dot_secret "myke/config.sh" "templates/dot-secrets/myke/config.sh.example"
    [ "${status}" -ne 0 ]
    [[ "${output}" == *"Error: required .dot-secrets file not found"* ]]
    [[ "${output}" == *"myke/config.sh"* ]]
    [[ "${output}" == *"templates/dot-secrets/myke/config.sh.example"* ]]
}

@test "require_dot_secret diagnostic omits template hint when not provided" {
    run require_dot_secret "absent/file.sh"
    [ "${status}" -ne 0 ]
    [[ "${output}" == *"Error: required .dot-secrets file not found"* ]]
    [[ "${output}" != *"template:"* ]]
}
