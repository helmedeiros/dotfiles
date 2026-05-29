#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

LIB_SH="${BATS_TEST_DIRNAME}/../../lib/git-identity.sh"
TEMPLATE="${BATS_TEST_DIRNAME}/../../git/gitconfig.symlink.example"

setup() {
    TEST_HOME="$(mktemp -d)"
    export DOT_SECRETS_ROOT="${TEST_HOME}/.dot-secrets"
    mkdir -p "${DOT_SECRETS_ROOT}/git"
    # shellcheck source=/dev/null
    source "${LIB_SH}"
}

teardown() {
    rm -rf "${TEST_HOME}"
    unset GIT_AUTHOR_NAME GIT_AUTHOR_EMAIL
}

# --- render_gitconfig ---

@test "render_gitconfig substitutes name, email and credential helper" {
    local out="${TEST_HOME}/gitconfig"
    render_gitconfig "${TEMPLATE}" "${out}" "Jane Doe" "jane@example.test" "osxkeychain"

    grep -q "name = Jane Doe" "${out}"
    grep -q "email = jane@example.test" "${out}"
    grep -q "helper = osxkeychain" "${out}"
}

@test "render_gitconfig handles names containing forward slashes" {
    # The original setup_gitconfig used '/' as sed delimiter and broke on
    # any '/' in the inputs. Verify the new '|' delimiter is robust.
    local out="${TEST_HOME}/gitconfig"
    render_gitconfig "${TEMPLATE}" "${out}" "A/B" "a/b@example.test" "cache"

    grep -q "name = A/B" "${out}"
    grep -q "email = a/b@example.test" "${out}"
}

@test "render_gitconfig fails when the template is missing" {
    run render_gitconfig "${TEST_HOME}/missing.template" "${TEST_HOME}/out" \
        "X" "x@y" "cache"
    [ "${status}" -ne 0 ]
    [[ "${output}" == *"template not found"* ]]
}

# --- load_git_identity_from_secrets ---

@test "load_git_identity_from_secrets returns 0 when both values are present" {
    cat > "${DOT_SECRETS_ROOT}/git/identity.sh" <<'EOF'
GIT_AUTHOR_NAME="Jane Doe"
GIT_AUTHOR_EMAIL="jane@example.test"
EOF

    load_git_identity_from_secrets
    [ "${GIT_AUTHOR_NAME}" = "Jane Doe" ]
    [ "${GIT_AUTHOR_EMAIL}" = "jane@example.test" ]
}

@test "load_git_identity_from_secrets returns 1 when the secrets file is absent" {
    run load_git_identity_from_secrets
    [ "${status}" -eq 1 ]
}

@test "load_git_identity_from_secrets returns 1 when name is empty" {
    cat > "${DOT_SECRETS_ROOT}/git/identity.sh" <<'EOF'
GIT_AUTHOR_NAME=""
GIT_AUTHOR_EMAIL="jane@example.test"
EOF

    run load_git_identity_from_secrets
    [ "${status}" -eq 1 ]
}

@test "load_git_identity_from_secrets returns 1 when email is empty" {
    cat > "${DOT_SECRETS_ROOT}/git/identity.sh" <<'EOF'
GIT_AUTHOR_NAME="Jane Doe"
GIT_AUTHOR_EMAIL=""
EOF

    run load_git_identity_from_secrets
    [ "${status}" -eq 1 ]
}

# --- default_credential_helper ---

@test "default_credential_helper returns a non-empty value" {
    run default_credential_helper
    [ "${status}" -eq 0 ]
    [ -n "${output}" ]
}

@test "default_credential_helper returns osxkeychain on Darwin" {
    if [ "$(uname -s)" != "Darwin" ]; then
        skip "Darwin-only assertion"
    fi
    run default_credential_helper
    [ "${output}" = "osxkeychain" ]
}
