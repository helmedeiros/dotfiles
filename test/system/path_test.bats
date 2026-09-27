#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

DOTFILES="${BATS_TEST_DIRNAME}/../.."
PATH_ZSH="${DOTFILES}/system/_path.zsh"

assert_sandboxed() {
    [ -n "${TEST_DIR}" ]
    [ "${HOME}" != "${REAL_HOME}" ]
}

setup() {
    REAL_HOME="${HOME}"
    TEST_DIR="$(mktemp -d)"
    export HOME="${TEST_DIR}/home"
    mkdir -p "${HOME}"
    assert_sandboxed
}

teardown() {
    [ -n "${TEST_DIR}" ] && rm -rf "${TEST_DIR}"
}

resulting_path() {
    env HOME="${HOME}" ZSH="${DOTFILES}" PATH="/usr/bin:/bin" \
        zsh -fc "source '${PATH_ZSH}'; print -r -- \$PATH"
}

@test "PATH contains no relative entry" {
    local path
    path="$(resulting_path)"

    run bash -c "printf '%s' \"${path}\" | tr ':' '\n' | grep -vE '^/' | grep -v '^$'"
    [ "${status}" -ne 0 ]
}

@test "PATH contains no empty entry" {
    local path
    path="$(resulting_path)"

    [[ "${path}" != *"::"* ]]
    [[ "${path}" != :* ]]
    [[ "${path}" != *: ]]
}

@test "a repo-local bin directory cannot shadow a command" {
    mkdir -p "${TEST_DIR}/project/bin"
    cat > "${TEST_DIR}/project/bin/totally-not-installed" <<'EOL'
#!/bin/sh
echo hijacked
EOL
    chmod +x "${TEST_DIR}/project/bin/totally-not-installed"

    run -127 env HOME="${HOME}" ZSH="${DOTFILES}" PATH="/usr/bin:/bin" \
        zsh -fc "source '${PATH_ZSH}'; cd '${TEST_DIR}/project'; totally-not-installed"

    [[ "${output}" != *"hijacked"* ]]
}

@test "the user's own bin directories are still on PATH" {
    local path
    path="$(resulting_path)"

    [[ "${path}" == *"${HOME}/.local/bin"* ]]
    [[ "${path}" == *"${DOTFILES}/bin"* ]]
}

@test "MANPATH has no relative or empty entry" {
    local manpath
    manpath="$(env HOME="${HOME}" ZSH="${DOTFILES}" PATH="/usr/bin:/bin" \
        zsh -fc "source '${PATH_ZSH}'; print -r -- \$MANPATH")"

    run bash -c "printf '%s' \"${manpath}\" | tr ':' '\n' | grep -vE '^/' | grep -v '^$'"
    [ "${status}" -ne 0 ]
}
