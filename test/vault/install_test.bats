#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

DOTFILES="${BATS_TEST_DIRNAME}/../.."
INSTALL_SH="${DOTFILES}/vault/install.sh"

assert_sandboxed() {
    [ -n "${TEST_DIR}" ]
    [ "${HOME}" != "${REAL_HOME}" ]
    case "${VAULT_BIN_DIR}" in
        "${TEST_DIR}"*) ;;
        *) echo "install dir escaped the sandbox: ${VAULT_BIN_DIR}" >&2; return 1 ;;
    esac
}

make_release() {
    local body="${1:-#!/bin/sh
echo Vault vSTUB}"
    rm -rf "${TEST_DIR}/build"
    mkdir -p "${TEST_DIR}/build"
    printf '%s\n' "$body" > "${TEST_DIR}/build/vault"
    chmod +x "${TEST_DIR}/build/vault"
    ( cd "${TEST_DIR}/build" && zip -q "${TEST_DIR}/release.zip" vault )
    shasum -a 256 "${TEST_DIR}/release.zip" | awk '{print $1}'
}

setup() {
    REAL_HOME="${HOME}"
    TEST_DIR="$(mktemp -d)"
    export HOME="${TEST_DIR}/home"
    mkdir -p "${HOME}"

    export VAULT_BIN_DIR="${TEST_DIR}/bin-install"
    mkdir -p "${VAULT_BIN_DIR}"

    SUDO_LOG="${TEST_DIR}/sudo.log"
    CURL_LOG="${TEST_DIR}/curl.log"
    : > "${SUDO_LOG}"
    : > "${CURL_LOG}"

    mkdir -p "${TEST_DIR}/bin"

    cat > "${TEST_DIR}/bin/sudo" <<EOL
#!/usr/bin/env bash
printf '%s\n' "\$*" >> "${SUDO_LOG}"
exec "\$@"
EOL

    cat > "${TEST_DIR}/bin/curl" <<EOL
#!/usr/bin/env bash
printf '%s\n' "\$*" >> "${CURL_LOG}"
out=""
prev=""
for a in "\$@"; do
    [ "\$prev" = "-o" ] && out="\$a"
    prev="\$a"
done
[ -n "\$out" ] || exit 0
if [ -f "${TEST_DIR}/release.zip" ]; then
    cp "${TEST_DIR}/release.zip" "\$out"
else
    exit 22
fi
EOL

    chmod +x "${TEST_DIR}/bin/sudo" "${TEST_DIR}/bin/curl"
    export PATH="${TEST_DIR}/bin:${PATH}"

    assert_sandboxed
}

teardown() {
    [ -n "${TEST_DIR}" ] && rm -rf "${TEST_DIR}"
}

run_install() {
    run env HOME="${HOME}" VAULT_BIN_DIR="${VAULT_BIN_DIR}" \
        VAULT_SHA256="$1" PATH="${TEST_DIR}/bin:/usr/bin:/bin" \
        bash "${INSTALL_SH}"
}

@test "verifies the download before installing it" {
    run grep -nE 'download_verified|verify_sha256|shasum -a 256' "${INSTALL_SH}"
    [ "${status}" -eq 0 ]
}

@test "pins a checksum for every architecture it downloads" {
    run grep -c 'VAULT_SHA256' "${INSTALL_SH}"
    [ "${status}" -eq 0 ]
}

@test "installs the binary when the checksum matches" {
    sha="$(make_release)"

    run_install "${sha}"

    [ "${status}" -eq 0 ]
    [ -x "${VAULT_BIN_DIR}/vault" ]
}

@test "refuses to install when the checksum does not match" {
    make_release >/dev/null

    run_install "0000000000000000000000000000000000000000000000000000000000000000"

    [ "${status}" -ne 0 ]
    [ ! -e "${VAULT_BIN_DIR}/vault" ]
    [[ "${output}" == *"SHA-256"* || "${output}" == *"checksum"* || "${output}" == *"mismatch"* ]]
}

@test "a tampered archive is rejected even though the download succeeded" {
    sha="$(make_release)"
    make_release "#!/bin/sh
echo pwned" >/dev/null

    run_install "${sha}"

    [ "${status}" -ne 0 ]
    [ ! -e "${VAULT_BIN_DIR}/vault" ]
}

@test "never runs sudo when verification fails" {
    make_release >/dev/null

    run_install "0000000000000000000000000000000000000000000000000000000000000000"

    [ ! -s "${SUDO_LOG}" ]
}

@test "fails cleanly when the download itself fails" {
    rm -f "${TEST_DIR}/release.zip"

    run_install "0000000000000000000000000000000000000000000000000000000000000000"

    [ "${status}" -ne 0 ]
    [ ! -e "${VAULT_BIN_DIR}/vault" ]
    [ ! -s "${SUDO_LOG}" ]
}

@test "downloads over https" {
    sha="$(make_release)"

    run_install "${sha}"

    grep -q 'https://' "${CURL_LOG}"
    run grep -q 'http://' "${CURL_LOG}"
    [ "${status}" -ne 0 ]
}
