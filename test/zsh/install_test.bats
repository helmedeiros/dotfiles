#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

DOTFILES="${BATS_TEST_DIRNAME}/../.."
INSTALL_SH="${DOTFILES}/zsh/install.sh"

assert_sandboxed() {
    [ -n "${TEST_DIR}" ]
    [ "${HOME}" != "${REAL_HOME}" ]
    case "${HOME}" in
        "${TEST_DIR}"*) ;;
        *) echo "HOME escaped the sandbox: ${HOME}" >&2; return 1 ;;
    esac
}

make_recorder() {
    local path="$1" log="$2"
    mkdir -p "$(dirname "$path")"
    cat > "$path" <<EOL
#!/usr/bin/env bash
printf '%s\n' "\$*" >> "${log}"
EOL
    chmod +x "$path"
}

setup() {
    REAL_HOME="${HOME}"
    TEST_DIR="$(mktemp -d)"
    export HOME="${TEST_DIR}/home"
    mkdir -p "${HOME}"

    SUDO_LOG="${TEST_DIR}/sudo.log"
    CHSH_LOG="${TEST_DIR}/chsh.log"
    : > "${SUDO_LOG}"
    : > "${CHSH_LOG}"

    make_recorder "${TEST_DIR}/bin/sudo" "${SUDO_LOG}"
    make_recorder "${TEST_DIR}/bin/chsh" "${CHSH_LOG}"

    make_recorder "${TEST_DIR}/bin/zsh" "${TEST_DIR}/zsh.log"

    export PATH="${TEST_DIR}/bin:${PATH}"

    BREW_PREFIX="${TEST_DIR}/brew"
    mkdir -p "${BREW_PREFIX}/share/zsh/site-functions"
    cat > "${TEST_DIR}/bin/brew" <<EOL
#!/usr/bin/env bash
[ "\$1" = "--prefix" ] && printf '%s\n' "${BREW_PREFIX}"
EOL
    chmod +x "${TEST_DIR}/bin/brew"

    export SHELLS_FILE="${TEST_DIR}/shells"
    printf '/bin/sh\n/bin/zsh\n' > "${SHELLS_FILE}"

    export SHELL="/bin/zsh"

    assert_sandboxed
}

teardown() {
    [ -n "${TEST_DIR}" ] && rm -rf "${TEST_DIR}"
}

run_install() {
    run env HOME="${HOME}" SHELLS_FILE="${SHELLS_FILE}" SHELL="${SHELL}" \
        sh "${INSTALL_SH}"
}

@test "does not pipe a downloaded script into a shell" {
    run grep -nE 'curl[^|]*\|[[:space:]]*(sudo[[:space:]]+)?(ba)?sh|wget[^|]*\|[[:space:]]*(ba)?sh' "${INSTALL_SH}"
    [ "${status}" -ne 0 ]
}

@test "does not install oh-my-zsh" {
    run grep -inE '^[^#]*oh-my-zsh' "${INSTALL_SH}"
    [ "${status}" -ne 0 ]
}

@test "every sudo invocation targets an absolute path" {
    local bad=0
    while IFS= read -r line; do
        [ -n "$line" ] || continue
        target="${line##* }"
        target="${target%\"}"
        case "$target" in
            /*) ;;
            \"\$*|\$*) ;;
            *) echo "sudo target is not absolute: $line" >&2; bad=1 ;;
        esac
    done <<< "$(grep -E '^[^#]*sudo ' "${INSTALL_SH}" || true)"
    [ "$bad" -eq 0 ]
}

@test "does not chown Homebrew's tree to root" {
    run grep -nE '^[^#]*chown' "${INSTALL_SH}"
    [ "${status}" -ne 0 ]
}

@test "succeeds and touches nothing privileged on a healthy setup" {
    chmod -R go-w "${BREW_PREFIX}/share/zsh"

    run_install

    [ "${status}" -eq 0 ]
    [ ! -s "${SUDO_LOG}" ]
    [ ! -s "${CHSH_LOG}" ]
}

@test "tightens a group-writable completion directory, by absolute path" {
    chmod g+w "${BREW_PREFIX}/share/zsh/site-functions"

    run_install

    [ "${status}" -eq 0 ]
    grep -q "${BREW_PREFIX}/share/zsh" "${SUDO_LOG}"
    run grep -E '(^| )zsh$' "${SUDO_LOG}"
    [ "${status}" -ne 0 ]
}

@test "skips the permission fix when Homebrew is absent" {
    rm -f "${TEST_DIR}/bin/brew"

    run_install

    [ "${status}" -eq 0 ]
    [ ! -s "${SUDO_LOG}" ]
}

@test "skips the permission fix when the share directory does not exist" {
    rm -rf "${BREW_PREFIX}/share/zsh"

    run_install

    [ "${status}" -eq 0 ]
    [ ! -s "${SUDO_LOG}" ]
}

@test "leaves the login shell alone when it is already zsh" {
    export SHELL="/bin/zsh"

    run_install

    [ "${status}" -eq 0 ]
    [ ! -s "${CHSH_LOG}" ]
}

@test "switches the login shell to a zsh that /etc/shells lists" {
    export SHELL="/bin/bash"

    run_install

    [ "${status}" -eq 0 ]
    grep -q '/bin/zsh' "${CHSH_LOG}"
}

@test "does not call chsh when no zsh is listed in /etc/shells" {
    export SHELL="/bin/bash"
    printf '/bin/sh\n/bin/bash\n' > "${SHELLS_FILE}"

    run_install

    [ "${status}" -eq 0 ]
    [ ! -s "${CHSH_LOG}" ]
}

@test "skips cleanly when zsh is not installed at all" {
    run env HOME="${HOME}" SHELLS_FILE="${SHELLS_FILE}" SHELL="/bin/bash" \
        ZSH_BIN="" sh "${INSTALL_SH}"

    [ "${status}" -eq 0 ]
    [[ "${output}" == *"not installed"* ]]
    [ ! -s "${CHSH_LOG}" ]
    [ ! -s "${SUDO_LOG}" ]
}
