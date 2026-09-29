#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

DOTFILES="${BATS_TEST_DIRNAME}/../.."
SYMLINKS_SH="${DOTFILES}/lib/symlinks.sh"

assert_sandboxed() {
    [ -n "${TEST_DIR}" ]
    [ "${HOME}" != "${REAL_HOME}" ]
    case "${HOME}" in
        "${TEST_DIR}"*) ;;
        *) echo "HOME escaped the sandbox: ${HOME}" >&2; return 1 ;;
    esac
}

setup() {
    REAL_HOME="${HOME}"
    TEST_DIR="$(mktemp -d)"
    export HOME="${TEST_DIR}/home"
    export DOTFILES_ROOT="${TEST_DIR}/dotfiles"
    mkdir -p "${HOME}" "${DOTFILES_ROOT}"
    assert_sandboxed
}

teardown() {
    [ -n "${TEST_DIR}" ] && rm -rf "${TEST_DIR}"
}

add_symlink_source() {
    local topic="$1" name="$2" body="${3:-content}"
    mkdir -p "${DOTFILES_ROOT}/${topic}"
    printf '%s\n' "$body" > "${DOTFILES_ROOT}/${topic}/${name}"
}

run_install_dotfiles() {
    run env HOME="${HOME}" DOTFILES_ROOT="${DOTFILES_ROOT}" bash -c "
        info() { :; }
        user() { echo \"PROMPTED: \$*\"; }
        success() { :; }
        fail() { echo \"fail: \$*\" >&2; exit 1; }
        source '${SYMLINKS_SH}'
        install_dotfiles
    " < /dev/null
}

@test "links every .symlink file into HOME without its suffix" {
    add_symlink_source vim vimrc.symlink
    add_symlink_source tmux tmux.conf.symlink

    run_install_dotfiles

    [ "${status}" -eq 0 ]
    [ -L "${HOME}/.vimrc" ]
    [ -L "${HOME}/.tmux.conf" ]
    [ "$(readlink "${HOME}/.vimrc")" = "${DOTFILES_ROOT}/vim/vimrc.symlink" ]
}

@test "the linked file resolves to the source content" {
    add_symlink_source vim vimrc.symlink "set number"

    run_install_dotfiles

    [ "$(cat "${HOME}/.vimrc")" = "set number" ]
}

@test "ignores files that are not .symlink" {
    add_symlink_source vim vimrc.symlink
    add_symlink_source vim notes.md

    run_install_dotfiles

    [ ! -e "${HOME}/.notes" ]
    [ ! -e "${HOME}/.notes.md" ]
}

@test "re-running leaves the existing link untouched" {
    add_symlink_source vim vimrc.symlink

    run_install_dotfiles
    local before
    before="$(readlink "${HOME}/.vimrc")"

    run_install_dotfiles

    [ "${status}" -eq 0 ]
    [ "$(readlink "${HOME}/.vimrc")" = "${before}" ]
}

@test "a dotfiles path containing a space still links" {
    DOTFILES_ROOT="${TEST_DIR}/my dotfiles"
    export DOTFILES_ROOT
    mkdir -p "${DOTFILES_ROOT}"
    add_symlink_source vim vimrc.symlink

    run_install_dotfiles

    [ "${status}" -eq 0 ]
    [ -L "${HOME}/.vimrc" ]
    [ "$(readlink "${HOME}/.vimrc")" = "${DOTFILES_ROOT}/vim/vimrc.symlink" ]
}

@test "does not descend past the topic directory" {
    mkdir -p "${DOTFILES_ROOT}/topic/nested/deeper"
    printf 'x\n' > "${DOTFILES_ROOT}/topic/nested/deeper/buried.symlink"

    run_install_dotfiles

    [ ! -e "${HOME}/.buried" ]
}
