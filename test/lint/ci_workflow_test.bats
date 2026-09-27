#!/usr/bin/env bats
#
# Static guard for the GitHub Actions security workflow. We do not run the
# workflow locally — these tests verify shape: the file exists, parses as
# YAML, runs gitleaks, and triggers on the events we care about.

bats_require_minimum_version 1.5.0

DOTFILES_ROOT="${BATS_TEST_DIRNAME}/../.."
export WORKFLOW="${DOTFILES_ROOT}/.github/workflows/security.yml"
GITLEAKS_IGNORE="${DOTFILES_ROOT}/.gitleaksignore"
export DEPENDABOT="${DOTFILES_ROOT}/.github/dependabot.yml"

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

@test "security workflow checks out unshallowed" {
    grep -qE 'fetch-depth:[[:space:]]*0' "${WORKFLOW}"
}

@test "security workflow scans every commit on a schedule" {
    ruby -ryaml -e '
      wf = YAML.load_file(ENV["WORKFLOW"])
      on = wf[true] || wf["on"]
      abort "no schedule trigger" unless on.key?("schedule")
      abort "no manual trigger" unless on.key?("workflow_dispatch")
      history = wf["jobs"]["gitleaks-history"]
      abort "no full-history job" if history.nil?
      guard = history["if"].to_s
      abort "history job not bound to schedule" unless guard.include?("schedule")
      abort "history job not bound to dispatch" unless guard.include?("workflow_dispatch")
    '
}

@test "the per-event gitleaks job does not claim to scan history" {
    ruby -ryaml -e '
      wf = YAML.load_file(ENV["WORKFLOW"])
      guard = wf["jobs"]["gitleaks"]["if"].to_s
      abort "per-event job would also run on a schedule" if guard.empty?
      abort "per-event job not bound to push/pull_request" unless guard.include?("push")
    '
}

@test "security workflow requests minimum contents:read permission only" {
    # No need for write permissions — this is a read-only scan.
    grep -qE 'contents:[[:space:]]*read' "${WORKFLOW}"
    run ! grep -qE '(contents|issues|pull-requests):[[:space:]]*write' "${WORKFLOW}"
}

# --- .gitleaksignore shape ---

@test ".gitleaksignore exists" {
    [ -f "${GITLEAKS_IGNORE}" ]
}

@test ".gitleaksignore entries are fingerprints, never broad allowlists" {
    # Each non-comment, non-blank line must look like a fingerprint
    # (commit:path:rule:line). Path-level allowlists or regexes would be
    # too broad — a fingerprint pins one specific known-fake match.
    local non_comment
    non_comment=$(grep -vE '^\s*(#|$)' "${GITLEAKS_IGNORE}" || true)
    [ -n "${non_comment}" ]

    while IFS= read -r line; do
        [[ "${line}" =~ ^[0-9a-f]{40}:[^:]+:[a-z0-9_-]+:[0-9]+$ ]] || {
            echo "Not a fingerprint: ${line}" >&2
            return 1
        }
    done <<< "${non_comment}"
}

@test "every action is pinned to a full commit sha" {
    local bad=0
    while IFS= read -r line; do
        [ -n "$line" ] || continue
        ref="${line##*@}"
        ref="${ref%% *}"
        if ! [[ "$ref" =~ ^[0-9a-f]{40}$ ]]; then
            echo "action not pinned to a commit sha: $line" >&2
            bad=1
        fi
    done <<< "$(grep -hE '^[[:space:]]*(-[[:space:]]*)?uses:' "${BATS_TEST_DIRNAME}"/../../.github/workflows/*.yml || true)"
    [ "$bad" -eq 0 ]
}

@test "each pinned action records the tag it came from" {
    while IFS= read -r line; do
        [ -n "$line" ] || continue
        [[ "$line" == *"#"* ]]
    done <<< "$(grep -hE '^[[:space:]]*(-[[:space:]]*)?uses:' "${BATS_TEST_DIRNAME}"/../../.github/workflows/*.yml || true)"
}

@test "dependabot config exists" {
    [ -f "${DEPENDABOT}" ]
}

@test "dependabot config is valid YAML" {
    ruby -ryaml -e "YAML.load_file('${DEPENDABOT}')"
}

@test "dependabot watches the actions the workflows pin" {
    ruby -ryaml -e '
      config = YAML.load_file(ENV["DEPENDABOT"])
      ecosystems = config["updates"].map { |u| u["package-ecosystem"] }
      abort "github-actions not watched" unless ecosystems.include?("github-actions")
    '
}

@test "dependabot commits in the repo conventional-commit style" {
    ruby -ryaml -e '
      config = YAML.load_file(ENV["DEPENDABOT"])
      config["updates"].each do |u|
        prefix = u.dig("commit-message", "prefix")
        abort "update entry has no commit-message prefix" if prefix.nil? || prefix.empty?
      end
    '
}
