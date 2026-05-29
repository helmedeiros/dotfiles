#!/usr/bin/env bats
#
# Cross-cutting lint rules that scan the whole repository for anti-patterns.

bats_require_minimum_version 1.5.0

DOTFILES_DIR="${BATS_TEST_DIRNAME}/../.."

@test "no shell file redirects stdout+stderr to a file literally named dash" {
    # 'amp gt dash' (rendered as a redirect token) is not a special bash
    # construct — it writes to a file literally named '-' in the current
    # working directory. Use &>/dev/null instead. The test directory is
    # excluded so this rule definition does not match itself.
    local pattern='&>-'
    run bash -c "grep -rn --include='*.sh' --include='*.zsh' --include='*.symlink' --exclude-dir=test --exclude-dir=.git -- '${pattern}' '${DOTFILES_DIR}'"
    # grep exits 1 when no matches found — that is the green case.
    [ "${status}" -eq 1 ]
}

@test "no orphan file named '-' at the repo root" {
    [ ! -e "${DOTFILES_DIR}/-" ]
}

@test "no shell or symlink file hardcodes a /Users/<name>/ path" {
    # Hardcoded /Users/<name>/ paths break the moment the dotfiles run on a
    # different machine or under a different user account. Use \$HOME instead.
    # The test directory is excluded because mocks legitimately fabricate
    # /Users-shaped paths inside tempdirs.
    run bash -c "grep -rEn '/Users/[a-zA-Z0-9._-]+/' --include='*.sh' --include='*.zsh' --include='*.symlink' --exclude-dir=test --exclude-dir=.git -- '${DOTFILES_DIR}'"
    [ "${status}" -eq 1 ]
}

@test "secrets/dots.sh is not gitignored" {
    # The *secret* rule in .gitignore is over-broad and previously matched
    # the legit secrets/ directory; this test guards the negation rule.
    cd "${DOTFILES_DIR}"
    run git check-ignore secrets/dots.sh
    # check-ignore exits 1 when the path is NOT ignored — that is the green case.
    [ "${status}" -eq 1 ]
}

@test ".claude/ local state is gitignored" {
    # Claude Code writes per-project, per-machine settings into .claude/ that
    # should not be committed.
    cd "${DOTFILES_DIR}"
    run git check-ignore .claude/settings.local.json
    [ "${status}" -eq 0 ]
}

@test "gitignore catches credential-shaped files" {
    cd "${DOTFILES_DIR}"
    for path in secrets.json credentials.yaml credentials.yml secret.env credential.env password1.txt password.json foo.token bar.secret baz.secrets .netrc .aws/credentials; do
        run git check-ignore "${path}"
        [ "${status}" -eq 0 ] || { echo "missed: ${path}" >&2; return 1; }
    done
}

@test "gitignore does NOT block files about secret-management" {
    # The previous *secret* / *password* / *credential* patterns matched any
    # file whose name dealt with secret-management (e.g. lib/dot-secrets.sh)
    # even though those files carry no secret content. The narrow patterns
    # must keep these tracked-friendly.
    cd "${DOTFILES_DIR}"
    for path in lib/dot-secrets.sh test/lib/dot-secrets_test.bats templates/dot-secrets/README.md secrets/dots.sh; do
        run git check-ignore "${path}"
        [ "${status}" -eq 1 ] || { echo "wrongly ignored: ${path}" >&2; return 1; }
    done
}

# --- PII / employer-name guards ---
#
# Patterns themselves are personal and live in ~/.dot-secrets/lint/pii-patterns.sh
# so the public test source never contains a literal employer name or
# personal-name fragment. See templates/dot-secrets/lint/pii-patterns.sh.example
# for the expected shape.

@test "no tracked file (outside test/) matches any PII / employer pattern" {
    # shellcheck source=../../lib/dot-secrets.sh
    source "${DOTFILES_DIR}/lib/dot-secrets.sh"

    PII_PATTERNS=()
    source_dot_secret "lint/pii-patterns.sh" || \
        skip "no ~/.dot-secrets/lint/pii-patterns.sh — see templates/dot-secrets/lint/"

    [ "${#PII_PATTERNS[@]}" -gt 0 ] || \
        skip "PII_PATTERNS array is empty in ~/.dot-secrets/lint/pii-patterns.sh"

    cd "${DOTFILES_DIR}"
    local pattern description hits failures=()

    for entry in "${PII_PATTERNS[@]}"; do
        pattern="${entry%%::*}"
        description="${entry##*::}"

        hits=$(git ls-files | grep -v '^test/' | xargs grep -lE "${pattern}" 2>/dev/null || true)
        if [ -n "${hits}" ]; then
            failures+=("${description}: ${hits}")
        fi
    done

    if [ "${#failures[@]}" -gt 0 ]; then
        printf '%s\n' "${failures[@]}" >&2
        return 1
    fi
    return 0
}
