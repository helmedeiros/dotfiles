#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

DOTFILES="${BATS_TEST_DIRNAME}/../.."
COMPINIT_ZSH="${DOTFILES}/lib/compinit.zsh"
ZSHRC="${DOTFILES}/zsh/zshrc.symlink"

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

invoke() {
    env HOME="${HOME}" ZDOTDIR="${1:-}" zsh -fc "
        compinit() { print -r -- \"compinit \$*\"; }
        autoload() { : }
        source '${COMPINIT_ZSH}'
        dotfiles_compinit
    "
}

make_dump() {
    local dir="$1" age="$2"
    mkdir -p "$dir"
    : > "$dir/.zcompdump"
    if [ -n "$age" ]; then
        touch -t "$age" "$dir/.zcompdump"
    fi
}

@test "zshrc does not glob an unset ZDOTDIR" {
    run grep -nE '\$\{ZDOTDIR\}/' "${ZSHRC}"
    [ "${status}" -ne 0 ]
}

@test "zshrc delegates to dotfiles_compinit" {
    run grep -q 'dotfiles_compinit' "${ZSHRC}"
    [ "${status}" -eq 0 ]
}

@test "a fresh dump takes the fast path" {
    make_dump "${HOME}" ""

    run invoke ""

    [[ "${output}" == *"-C"* ]]
    [[ "${output}" == *"${HOME}/.zcompdump"* ]]
}

@test "a dump older than a day is rebuilt with the security check" {
    make_dump "${HOME}" "202401010000"

    run invoke ""

    [[ "${output}" != *"-C"* ]]
    [[ "${output}" == *"-d ${HOME}/.zcompdump"* ]]
}

@test "a missing dump is built with the security check" {
    run invoke ""

    [[ "${output}" != *"-C"* ]]
    [[ "${output}" == *"-d ${HOME}/.zcompdump"* ]]
}

@test "ZDOTDIR is honoured when it is set" {
    mkdir -p "${TEST_DIR}/zdot"
    make_dump "${TEST_DIR}/zdot" ""

    run invoke "${TEST_DIR}/zdot"

    [[ "${output}" == *"${TEST_DIR}/zdot/.zcompdump"* ]]
}

@test "the dump path is always passed explicitly" {
    run invoke ""

    [[ "${output}" == *"-d "* ]]
}
