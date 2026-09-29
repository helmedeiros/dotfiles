#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

DOTFILES="${BATS_TEST_DIRNAME}/../.."
CHECK="${DOTFILES}/script/check-precommit-pins"

setup() {
    TEST_DIR="$(mktemp -d)"
    mkdir -p "${TEST_DIR}/bin"
    export PATH="${TEST_DIR}/bin:${PATH}"
}

teardown() {
    [ -n "${TEST_DIR}" ] && rm -rf "${TEST_DIR}"
}

stub_gh() {
    cat > "${TEST_DIR}/bin/gh" <<EOL
#!/usr/bin/env bash
case "\$2" in
$1
esac
EOL
    chmod +x "${TEST_DIR}/bin/gh"
}

write_config() {
    cat > "${TEST_DIR}/config.yaml" <<EOL
repos:
  - repo: https://github.com/acme/tool
    rev: $1
    hooks:
      - id: tool
EOL
}

@test "passes when the pin matches the latest release" {
    write_config v1.2.3
    stub_gh '  repos/acme/tool/releases/latest) echo v1.2.3 ;;'

    run "${CHECK}" "${TEST_DIR}/config.yaml"

    [ "${status}" -eq 0 ]
    [[ "${output}" == *"ok"* ]]
}

@test "fails when the pin is behind the latest release" {
    write_config v1.2.0
    stub_gh '  repos/acme/tool/releases/latest) echo v1.2.3 ;;'

    run "${CHECK}" "${TEST_DIR}/config.yaml"

    [ "${status}" -ne 0 ]
    [[ "${output}" == *"STALE"* ]]
    [[ "${output}" == *"v1.2.3"* ]]
}

@test "skips a repository that publishes no releases" {
    write_config v1.2.0
    stub_gh '  repos/acme/tool/releases/latest) echo "not found" >&2; exit 1 ;;'

    run "${CHECK}" "${TEST_DIR}/config.yaml"

    [ "${status}" -eq 0 ]
    [[ "${output}" == *"skip"* ]]
}

@test "a 404 body on stdout is not mistaken for a version" {
    write_config v1.2.0
    stub_gh '  repos/acme/tool/releases/latest) echo "{\"message\":\"Not Found\"}"; exit 1 ;;'

    run "${CHECK}" "${TEST_DIR}/config.yaml"

    [ "${status}" -eq 0 ]
    [[ "${output}" != *"Not Found"* ]]
}

@test "reads every pinned repository in the config" {
    cat > "${TEST_DIR}/config.yaml" <<'EOL'
repos:
  - repo: https://github.com/acme/one
    rev: v1.0.0
    hooks:
      - id: one
  - repo: https://github.com/acme/two
    rev: v2.0.0
    hooks:
      - id: two
EOL
    stub_gh '  repos/acme/one/releases/latest) echo v1.0.0 ;;
  repos/acme/two/releases/latest) echo v2.0.0 ;;'

    run "${CHECK}" "${TEST_DIR}/config.yaml"

    [ "${status}" -eq 0 ]
    [[ "${output}" == *"acme/one"* ]]
    [[ "${output}" == *"acme/two"* ]]
}
