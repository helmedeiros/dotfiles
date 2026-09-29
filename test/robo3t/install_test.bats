#!/usr/bin/env bats
#
# robo3t/install.sh has three states: Robo 3T absent, Robo 3T present but
# never launched, and Robo 3T configured. Only the third one does any work —
# the other two are skips, and a skip must not be reported as an installer
# failure by script/install.
#
# The app location is read from $ROBO3T_APP so both branches are reachable
# without a real /Applications/Robo 3T.app.

bats_require_minimum_version 1.5.0

DOTFILES="${BATS_TEST_DIRNAME}/../.."
INSTALL_SH="${DOTFILES}/robo3t/install.sh"

setup() {
    TEST_HOME="$(mktemp -d)"
    export HOME="${TEST_HOME}"
    export ROBO3T_APP="${TEST_HOME}/Applications/Robo 3T.app"
}

teardown() {
    rm -rf "${TEST_HOME}"
}

install_app() {
    mkdir -p "${ROBO3T_APP}/Contents"
}

launch_app_once() {
    VERSION_DIR="${HOME}/.3T/robo-3t/1.4.4"
    mkdir -p "${VERSION_DIR}"
}

write_secrets_config() {
    mkdir -p "${HOME}/.dot-secrets/robo3t"
    printf '%s\n' "$1" > "${HOME}/.dot-secrets/robo3t/robo3t.json"
}

@test "skips without failing when Robo 3T is not installed" {
    run bash "${INSTALL_SH}"

    [ "${status}" -eq 0 ]
    [[ "${output}" == *"not installed"* ]]
}

@test "skips without failing when Robo 3T has never been launched" {
    install_app

    run bash "${INSTALL_SH}"

    [ "${status}" -eq 0 ]
    [[ "${output}" == *"at least once"* ]]
}

@test "skips without failing when .dot-secrets is absent" {
    install_app
    launch_app_once

    run bash "${INSTALL_SH}"

    [ "${status}" -eq 0 ]
    [[ "${output}" == *".dot-secrets"* ]]
}

@test "skips without failing when .dot-secrets carries no robo3t config" {
    install_app
    launch_app_once
    mkdir -p "${HOME}/.dot-secrets"

    run bash "${INSTALL_SH}"

    [ "${status}" -eq 0 ]
    [[ "${output}" == *"not found in .dot-secrets"* ]]
}

@test "installs the configuration from .dot-secrets" {
    install_app
    launch_app_once
    write_secrets_config '{"connections":"from-secrets"}'

    run bash "${INSTALL_SH}"

    [ "${status}" -eq 0 ]
    grep -q 'from-secrets' "${VERSION_DIR}/robo3t.json"
}

@test "backs up an existing configuration before overwriting it" {
    install_app
    launch_app_once
    printf '%s\n' '{"connections":"existing"}' > "${VERSION_DIR}/robo3t.json"
    write_secrets_config '{"connections":"from-secrets"}'

    run bash "${INSTALL_SH}"

    [ "${status}" -eq 0 ]
    grep -q 'existing' "${VERSION_DIR}/robo3t.json.backup"
    grep -q 'from-secrets' "${VERSION_DIR}/robo3t.json"
}

@test "picks the newest version directory" {
    install_app
    mkdir -p "${HOME}/.3T/robo-3t/1.3.1" "${HOME}/.3T/robo-3t/1.4.4"
    write_secrets_config '{"connections":"from-secrets"}'

    run bash "${INSTALL_SH}"

    [ "${status}" -eq 0 ]
    grep -q 'from-secrets' "${HOME}/.3T/robo-3t/1.4.4/robo3t.json"
    [ ! -f "${HOME}/.3T/robo-3t/1.3.1/robo3t.json" ]
}

@test "keeps the original backup across repeated runs" {
    install_app
    launch_app_once
    write_secrets_config '{"connections":[]}'
    printf '{"mine":true}\n' > "${VERSION_DIR}/robo3t.json"

    run bash "${INSTALL_SH}"
    run bash "${INSTALL_SH}"
    run bash "${INSTALL_SH}"

    [ "$(cat "${VERSION_DIR}/robo3t.json.backup")" = '{"mine":true}' ]
}
