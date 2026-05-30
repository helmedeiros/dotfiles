#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

DOTFILES="${BATS_TEST_DIRNAME}/../.."
CONFIG="${DOTFILES}/.pre-commit-config.yaml"
INSTALL_SH="${DOTFILES}/pre-commit/install.sh"
BREWFILE="${DOTFILES}/Brewfile"

# --- config file shape ---

@test ".pre-commit-config.yaml exists and is valid YAML" {
    [ -f "${CONFIG}" ]
    ruby -ryaml -e "YAML.load_file('${CONFIG}')"
}

@test ".pre-commit-config.yaml runs gitleaks" {
    grep -q 'github.com/gitleaks/gitleaks' "${CONFIG}"
    grep -q 'id: gitleaks' "${CONFIG}"
}

@test ".pre-commit-config.yaml runs shellcheck" {
    grep -q 'github.com/shellcheck-py/shellcheck-py' "${CONFIG}"
    grep -q 'id: shellcheck' "${CONFIG}"
}

# --- Brewfile ---

@test "Brewfile installs pre-commit" {
    grep -qE "^brew 'pre-commit'" "${BREWFILE}"
}

# --- install.sh ---

@test "pre-commit/install.sh exists and is executable" {
    [ -x "${INSTALL_SH}" ]
}

@test "pre-commit/install.sh is a no-op when pre-commit binary is missing" {
    local fake_path="/usr/bin:/bin"
    PATH="${fake_path}" run "${INSTALL_SH}"
    [ "${status}" -eq 0 ]
    [[ "${output}" == *"pre-commit not on PATH"* ]]
}

@test "pre-commit/install.sh wires hooks idempotently when pre-commit is installed" {
    if ! command -v pre-commit &> /dev/null; then
        skip "pre-commit not installed"
    fi

    # Work in a tempdir-init'd git repo to avoid touching the real .git/hooks.
    TMP_REPO="$(mktemp -d)"
    git -C "${TMP_REPO}" init --quiet
    cp "${CONFIG}" "${TMP_REPO}/.pre-commit-config.yaml"

    # Copy install.sh into the same relative position so REPO_ROOT resolves.
    mkdir -p "${TMP_REPO}/pre-commit"
    cp "${INSTALL_SH}" "${TMP_REPO}/pre-commit/install.sh"

    run "${TMP_REPO}/pre-commit/install.sh"
    [ "${status}" -eq 0 ]
    [ -x "${TMP_REPO}/.git/hooks/pre-commit" ]

    # Re-running is a no-op (no error, hook still in place).
    run "${TMP_REPO}/pre-commit/install.sh"
    [ "${status}" -eq 0 ]
    [ -x "${TMP_REPO}/.git/hooks/pre-commit" ]

    rm -rf "${TMP_REPO}"
}
