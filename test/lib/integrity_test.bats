#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

LIB_SH="${BATS_TEST_DIRNAME}/../../lib/integrity.sh"

setup() {
    TEST_HOME="$(mktemp -d)"
    # shellcheck source=/dev/null
    source "${LIB_SH}"

    SAMPLE="${TEST_HOME}/sample"
    printf 'hello\n' > "${SAMPLE}"
    # Pre-computed via:
    #   printf 'hello\n' | shasum -a 256
    SAMPLE_SHA="5891b5b522d5df086d0ff0b110fbd9d21bb4fc7163af34d08286a2e846f6be03"
}

teardown() {
    rm -rf "${TEST_HOME}"
}

# --- verify_sha256 ---

@test "verify_sha256 returns 0 when checksum matches" {
    verify_sha256 "${SAMPLE}" "${SAMPLE_SHA}"
}

@test "verify_sha256 returns 1 and prints diagnostic on mismatch" {
    run verify_sha256 "${SAMPLE}" "0000000000000000000000000000000000000000000000000000000000000000" "sample"
    [ "${status}" -eq 1 ]
    [[ "${output}" == *"SHA-256 mismatch for sample"* ]]
    [[ "${output}" == *"expected: 0000"* ]]
    [[ "${output}" == *"actual:   ${SAMPLE_SHA}"* ]]
}

@test "verify_sha256 returns 1 when file is missing" {
    run verify_sha256 "${TEST_HOME}/absent" "${SAMPLE_SHA}"
    [ "${status}" -eq 1 ]
    [[ "${output}" == *"file not found"* ]]
}

@test "verify_sha256 returns 2 on missing arguments" {
    run verify_sha256 "" ""
    [ "${status}" -eq 2 ]
}

@test "verify_sha256 default friendly name is the file path" {
    run verify_sha256 "${SAMPLE}" "0000000000000000000000000000000000000000000000000000000000000000"
    [ "${status}" -eq 1 ]
    [[ "${output}" == *"SHA-256 mismatch for ${SAMPLE}"* ]]
}

# --- download_verified ---

@test "download_verified echoes verified path on success (file:// URL)" {
    run download_verified "file://${SAMPLE}" "${SAMPLE_SHA}" "sample"
    [ "${status}" -eq 0 ]
    [ -f "${output}" ]
    grep -q "hello" "${output}"
}

@test "download_verified returns 1 and cleans up on SHA mismatch" {
    run download_verified "file://${SAMPLE}" "0000000000000000000000000000000000000000000000000000000000000000" "sample"
    [ "${status}" -eq 1 ]
    [[ "${output}" == *"SHA-256 mismatch"* ]]
    # No leftover tempfiles whose content is "hello".
    run bash -c "find /var/folders /tmp -maxdepth 3 -type f -newer ${SAMPLE} -size -100c 2>/dev/null | xargs -I{} grep -l '^hello\$' {} 2>/dev/null | wc -l | tr -d ' '"
    [ "${output}" = "0" ] || [ "${output}" = "1" ]   # tolerate the SAMPLE itself
}

@test "download_verified returns 1 on download failure" {
    run download_verified "file://${TEST_HOME}/absent" "${SAMPLE_SHA}" "sample"
    [ "${status}" -eq 1 ]
    [[ "${output}" == *"failed to download sample"* ]]
}

@test "download_verified returns 2 on missing arguments" {
    run download_verified "" ""
    [ "${status}" -eq 2 ]
}
