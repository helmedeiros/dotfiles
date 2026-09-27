#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

DOTFILES="${BATS_TEST_DIRNAME}/../.."
INSTALL_SH="${DOTFILES}/kubernetes/install.sh"

assert_sandboxed() {
    [ -n "${TEST_DIR}" ]
    [ "${HOME}" != "${REAL_HOME}" ]
    case "${HOME}" in
        "${TEST_DIR}"*) ;;
        *) echo "HOME escaped the sandbox: ${HOME}" >&2; return 1 ;;
    esac
}

write_secrets_config() {
    mkdir -p "${HOME}/.dot-secrets/kubernetes"
    cat > "${HOME}/.dot-secrets/kubernetes/config.sh" <<EOL
KUBE_CONFIG_URL="https://kube.example.test/config"
KUBE_CONFIG_FILENAME="config-test"
DEFAULT_CONTEXT="test-context"
EOL
}

serve() {
    printf '%s' "$1" > "${TEST_DIR}/response"
    printf '%s' "${2:-200}" > "${TEST_DIR}/status"
}

setup() {
    REAL_HOME="${HOME}"
    TEST_DIR="$(mktemp -d)"
    export HOME="${TEST_DIR}/home"
    mkdir -p "${HOME}"
    assert_sandboxed

    mkdir -p "${TEST_DIR}/bin"

    cat > "${TEST_DIR}/bin/curl" <<EOL
#!/usr/bin/env bash
status="\$(cat "${TEST_DIR}/status" 2>/dev/null || echo 200)"
fail=0
out=""
prev=""
for a in "\$@"; do
    case "\$a" in
        --fail|-f) fail=1 ;;
    esac
    [ "\$prev" = "-o" ] && out="\$a"
    prev="\$a"
done
if [ "\$status" != "200" ] && [ "\$fail" = "1" ]; then
    exit 22
fi
if [ -n "\$out" ]; then
    cat "${TEST_DIR}/response" > "\$out"
fi
exit 0
EOL

    cat > "${TEST_DIR}/bin/kubectl" <<'EOL'
#!/usr/bin/env bash
exit 0
EOL

    chmod +x "${TEST_DIR}/bin/curl" "${TEST_DIR}/bin/kubectl"
    export PATH="${TEST_DIR}/bin:/usr/bin:/bin"

    write_secrets_config
    serve "apiVersion: v1
kind: Config"
}

teardown() {
    [ -n "${TEST_DIR}" ] && rm -rf "${TEST_DIR}"
}

run_install() {
    run env HOME="${HOME}" PATH="${PATH}" bash "${INSTALL_SH}"
}

@test "the kubeconfig download fails the request on an HTTP error" {
    run grep -nE 'curl[^|]*(--fail|-f )' "${INSTALL_SH}"
    [ "${status}" -eq 0 ]
}

@test "downloads the kubeconfig and locks its permissions down" {
    run_install

    [ "${status}" -eq 0 ]
    [ -f "${HOME}/.kube/config-test" ]
    perms="$(stat -f '%Lp' "${HOME}/.kube/config-test")"
    [ "${perms}" = "600" ]
}

@test "an HTTP error does not leave a response body as the kubeconfig" {
    serve "<html>401 Unauthorized</html>" "401"

    run_install

    [ "${status}" -ne 0 ]
    [ ! -f "${HOME}/.kube/config-test" ]
}

@test "an HTTP error does not overwrite an existing kubeconfig" {
    mkdir -p "${HOME}/.kube"
    printf 'existing-config' > "${HOME}/.kube/config-test"
    serve "<html>500</html>" "500"

    run_install

    [ "${status}" -ne 0 ]
    [ "$(cat "${HOME}/.kube/config-test")" = "existing-config" ]
}

@test "does not write to a shell profile the dotfiles repo owns" {
    printf '# managed by the repo\n' > "${HOME}/.zshrc"
    before="$(cat "${HOME}/.zshrc")"

    run_install

    [ "${status}" -eq 0 ]
    [ "$(cat "${HOME}/.zshrc")" = "${before}" ]
}

@test "records KUBECONFIG in the untracked localrc instead" {
    run_install

    [ "${status}" -eq 0 ]
    grep -q 'KUBECONFIG' "${HOME}/.localrc"
    grep -q 'config-test' "${HOME}/.localrc"
}

@test "does not duplicate the localrc entry on a second run" {
    run_install
    run_install

    [ "$(grep -c 'KUBECONFIG' "${HOME}/.localrc")" -eq 1 ]
}
