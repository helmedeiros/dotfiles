#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

CLAUDE_DIR="${BATS_TEST_DIRNAME}/../../claude"
CLAUDE_MD="${CLAUDE_DIR}/CLAUDE.md"
LIB_SH="${CLAUDE_DIR}/lib.sh"
INSTALL_SH="${CLAUDE_DIR}/install.sh"

setup() {
    TEST_HOME="$(mktemp -d)"
    # shellcheck source=/dev/null
    source "${LIB_SH}"
}

teardown() {
    rm -rf "${TEST_HOME}"
}

# --- Source file content checks ---

@test "claude/CLAUDE.md exists and is non-empty" {
    [ -f "${CLAUDE_MD}" ]
    [ -s "${CLAUDE_MD}" ]
}

@test "claude/CLAUDE.md forbids Claude as co-author" {
    grep -qi 'co-author' "${CLAUDE_MD}"
    grep -qiE '(never|do not|don.t).*co-author' "${CLAUDE_MD}"
}

@test "claude/CLAUDE.md mandates small commits with quality gates" {
    grep -qi 'small' "${CLAUDE_MD}"
    grep -qi 'quality gates' "${CLAUDE_MD}"
}

@test "claude/lib.sh exists and is sourceable" {
    [ -f "${LIB_SH}" ]
    bash -n "${LIB_SH}"
}

@test "claude/install.sh sources lib.sh" {
    grep -q '\. "\$CLAUDE_DIR/lib.sh"' "${INSTALL_SH}"
}

@test "claude/install.sh links CLAUDE.md to ~/.claude/" {
    grep -q 'link_claude_file.*CLAUDE.md.*HOME/.claude/CLAUDE.md' "${INSTALL_SH}"
}

# --- link_claude_file behaviour ---

@test "link_claude_file creates symlink when destination is absent" {
    local src="${TEST_HOME}/source.md"
    local dst="${TEST_HOME}/target/CLAUDE.md"
    echo "hello" > "${src}"

    link_claude_file "${src}" "${dst}"

    [ -L "${dst}" ]
    [ "$(readlink "${dst}")" = "${src}" ]
}

@test "link_claude_file creates parent directories as needed" {
    local src="${TEST_HOME}/source.md"
    local dst="${TEST_HOME}/a/b/c/CLAUDE.md"
    echo "hello" > "${src}"

    link_claude_file "${src}" "${dst}"

    [ -L "${dst}" ]
    [ -d "${TEST_HOME}/a/b/c" ]
}

@test "link_claude_file is idempotent when symlink already points at source" {
    local src="${TEST_HOME}/source.md"
    local dst="${TEST_HOME}/CLAUDE.md"
    echo "hello" > "${src}"

    link_claude_file "${src}" "${dst}"
    link_claude_file "${src}" "${dst}"

    [ -L "${dst}" ]
    [ "$(readlink "${dst}")" = "${src}" ]
    # No backup files should have been created on the second run.
    run bash -c "ls ${TEST_HOME}/*.bak.* 2>/dev/null | wc -l | tr -d ' '"
    [ "${output}" = "0" ]
}

@test "link_claude_file backs up a real file at destination" {
    local src="${TEST_HOME}/source.md"
    local dst="${TEST_HOME}/CLAUDE.md"
    echo "new content" > "${src}"
    echo "user's existing notes" > "${dst}"

    link_claude_file "${src}" "${dst}"

    [ -L "${dst}" ]
    [ "$(readlink "${dst}")" = "${src}" ]
    # A backup file should exist preserving the original content.
    run bash -c "cat ${TEST_HOME}/CLAUDE.md.bak.* 2>/dev/null"
    [ "${output}" = "user's existing notes" ]
}

@test "link_claude_file backs up a symlink pointing elsewhere" {
    local src="${TEST_HOME}/source.md"
    local other="${TEST_HOME}/other.md"
    local dst="${TEST_HOME}/CLAUDE.md"
    echo "new" > "${src}"
    echo "other" > "${other}"
    ln -s "${other}" "${dst}"

    link_claude_file "${src}" "${dst}"

    [ -L "${dst}" ]
    [ "$(readlink "${dst}")" = "${src}" ]
    run bash -c "ls ${TEST_HOME}/CLAUDE.md.bak.* 2>/dev/null | wc -l | tr -d ' '"
    [ "${output}" = "1" ]
}

@test "link_claude_file fails when source does not exist" {
    local dst="${TEST_HOME}/CLAUDE.md"
    run link_claude_file "${TEST_HOME}/missing.md" "${dst}"
    [ "${status}" -ne 0 ]
    [ ! -e "${dst}" ]
}

@test "link_claude_file fails on missing arguments" {
    run link_claude_file "" ""
    [ "${status}" -ne 0 ]
}
