#!/usr/bin/env bats
#
# Static guard for the GitHub Actions security workflow. We do not run the
# workflow locally — these tests verify shape: the file exists, parses as
# YAML, runs gitleaks, and triggers on the events we care about.

bats_require_minimum_version 1.5.0

WORKFLOW="${BATS_TEST_DIRNAME}/../../.github/workflows/security.yml"

@test "security workflow file exists" {
    [ -f "${WORKFLOW}" ]
}

@test "security workflow is valid YAML" {
    # Ruby ships with macOS and has YAML built-in, no extra deps needed.
    ruby -ryaml -e "YAML.load_file('${WORKFLOW}')"
}

@test "security workflow triggers on push and pull_request" {
    grep -qE '^[[:space:]]*push:' "${WORKFLOW}"
    grep -qE '^[[:space:]]*pull_request:' "${WORKFLOW}"
}

@test "security workflow runs gitleaks-action" {
    grep -q 'gitleaks/gitleaks-action@' "${WORKFLOW}"
}

@test "security workflow checks out with full history (gitleaks needs it)" {
    grep -qE 'fetch-depth:[[:space:]]*0' "${WORKFLOW}"
}

@test "security workflow requests minimum contents:read permission only" {
    # No need for write permissions — this is a read-only scan.
    grep -qE 'contents:[[:space:]]*read' "${WORKFLOW}"
    ! grep -qE '(contents|issues|pull-requests):[[:space:]]*write' "${WORKFLOW}"
}
