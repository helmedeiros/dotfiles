#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

DOTFILES="${BATS_TEST_DIRNAME}/../.."
ROOMS_SH="${DOTFILES}/emulator/rooms.sh"

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
    mkdir -p "${HOME}" "${TEST_DIR}/bin"
    assert_sandboxed

    GIT_LOG="${TEST_DIR}/git.log"
    : > "${GIT_LOG}"

    cat > "${TEST_DIR}/bin/git" <<EOL
#!/usr/bin/env bash
printf '%s\n' "\$*" >> "${GIT_LOG}"
exit 0
EOL
    chmod +x "${TEST_DIR}/bin/git"
    export PATH="${TEST_DIR}/bin:${PATH}"
}

teardown() {
    [ -n "${TEST_DIR}" ] && rm -rf "${TEST_DIR}"
}

invoke() {
    env "$@" HOME="${HOME}" PATH="${PATH}" bash -c "
        set -e
        info() { echo \"info: \$*\"; }
        user() { echo \"user: \$*\"; }
        success() { echo \"success: \$*\"; }
        fail() { echo \"fail: \$*\" >&2; exit 1; }
        source '${ROOMS_SH}'
        setup_rooms
    " </dev/null
}

no_clone_happened() {
    run grep -q 'clone' "${GIT_LOG}"
    [ "${status}" -ne 0 ]
    [ ! -e "${HOME}/.rooms" ]
}

@test "refuses to clone the rooms repo when CI is set" {
    run invoke CI=true

    [ "${status}" -eq 0 ]
    no_clone_happened
}

@test "refuses to clone the rooms repo on a GitHub Actions runner" {
    run invoke GITHUB_ACTIONS=true

    [ "${status}" -eq 0 ]
    no_clone_happened
}

@test "refuses to clone the rooms repo when stdin is not a terminal" {
    run invoke SOME_VAR=1

    [ "${status}" -eq 0 ]
    no_clone_happened
}

@test "an unattended run does not abort the bootstrap it is part of" {
    run invoke CI=true

    [ "${status}" -eq 0 ]
    [[ "${output}" == *"refusing to clone"* ]]
}

@test "does nothing when the rooms repo is already present" {
    mkdir -p "${HOME}/.rooms"

    run invoke CI=true

    [ "${status}" -eq 0 ]
    run grep -q 'clone' "${GIT_LOG}"
    [ "${status}" -ne 0 ]
}
