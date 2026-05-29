#!/usr/bin/env bats
#
# Exercises kubernetes/path.zsh against a controlled $HOME so the
# .dot-secrets-driven KUBECONFIG resolution is testable without touching
# the real environment.

bats_require_minimum_version 1.5.0

PATH_ZSH="${BATS_TEST_DIRNAME}/../../kubernetes/path.zsh"

setup() {
    TEST_HOME="$(mktemp -d)"
    export HOME="${TEST_HOME}"
    mkdir -p "${TEST_HOME}/.kube" "${TEST_HOME}/.dot-secrets/kubernetes"
    unset KUBECONFIG KUBE_CONFIG_FILENAME
}

teardown() {
    rm -rf "${TEST_HOME}"
    unset KUBECONFIG KUBE_CONFIG_FILENAME
}

# Source path.zsh in a sub-bash so KUBECONFIG can be inspected via stdout.
_run_path_zsh() {
    bash -c "HOME='${TEST_HOME}' source '${PATH_ZSH}' && printf '%s' \"\${KUBECONFIG:-}\""
}

# --- Runtime behaviour ---
#
# Reintroducing a hardcoded employer-specific kubeconfig filename is caught
# by the cross-cutting PII guard in test/lint/lint_test.bats (driven by
# ~/.dot-secrets/lint/pii-patterns.sh), so this file stays focused on the
# runtime semantics of path.zsh.

@test "KUBECONFIG points at .dot-secrets KUBE_CONFIG_FILENAME when present" {
    cat > "${TEST_HOME}/.dot-secrets/kubernetes/config.sh" <<'EOF'
KUBE_CONFIG_FILENAME="cluster-a.conf"
EOF
    : > "${TEST_HOME}/.kube/cluster-a.conf"

    run _run_path_zsh
    [ "${output}" = "${TEST_HOME}/.kube/cluster-a.conf" ]
}

@test "KUBECONFIG falls back to ~/.kube/config when no .dot-secrets override" {
    : > "${TEST_HOME}/.kube/config"

    run _run_path_zsh
    [ "${output}" = "${TEST_HOME}/.kube/config" ]
}

@test "KUBECONFIG is left unset when neither override nor default exists" {
    run _run_path_zsh
    [ -z "${output}" ]
}

@test "KUBECONFIG is left unset when KUBE_CONFIG_FILENAME points at a missing file" {
    cat > "${TEST_HOME}/.dot-secrets/kubernetes/config.sh" <<'EOF'
KUBE_CONFIG_FILENAME="nonexistent.conf"
EOF

    run _run_path_zsh
    [ -z "${output}" ]
}
