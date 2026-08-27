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

@test "run_tests.sh discovers test suites instead of hardcoding them" {
    # A hand-maintained list means a new topic's tests only run if someone
    # remembers to register them — they are otherwise skipped silently, which
    # looks identical to passing.
    # No suite that exists on disk may be named literally in the runner.
    for d in "${DOTFILES_DIR}"/test/*/; do
        local suite
        suite="$(basename "$d")"
        compgen -G "${d}*_test.bats" > /dev/null || continue
        grep -q "Running ${suite} tests" "${DOTFILES_DIR}/test/run_tests.sh" && {
            echo "run_tests.sh hardcodes the ${suite} suite"
            false
        }
    done

    grep -q 'for suite_dir in' "${DOTFILES_DIR}/test/run_tests.sh"
}

@test "every consumer of Node reads the pin from node/.nvmrc" {
    # bin/dot, node/install.sh and bin/check-updates must agree on the runtime.
    # A consumer left on --lts silently drifts the day LTS moves on.
    # Must actually READ the file: a mention in a comment while the code still
    # says --lts is exactly the drift this guards against, so strip comments
    # first and require a real `cat` of node/.nvmrc.
    for consumer in bin/dot node/install.sh bin/check-updates; do
        grep -vE '^[[:space:]]*#' "${DOTFILES_DIR}/${consumer}" \
            | grep -q 'cat .*node/\.nvmrc' || {
            echo "${consumer} does not read node/.nvmrc"
            false
        }
    done
}

@test "shellcheck allowlist contains no entry that is already clean" {
    # Without this the list would only ever grow stale: a script gets fixed,
    # its exemption stays, and the next regression in it goes unnoticed.
    local allowlist="${DOTFILES_DIR}/test/shellcheck-allowlist.txt"
    [ -f "$allowlist" ]

    while IFS= read -r rel; do
        [ -z "$rel" ] && continue
        case "$rel" in \#*) continue ;; esac
        [ -f "${DOTFILES_DIR}/${rel}" ] || {
            echo "allowlist names a file that no longer exists: ${rel}"
            false
        }
        if shellcheck -S warning "${DOTFILES_DIR}/${rel}" > /dev/null 2>&1; then
            echo "${rel} is clean now — remove it from the allowlist"
            false
        fi
    done < "$allowlist"
}

@test "no tracked shell script has an error-level shellcheck finding" {
    # Errors are never exempt: SC2145 in functions/gi and go/install.sh were
    # real bugs, not style — a multi-argument call fetched the wrong URL and
    # installed unpinned versions respectively.
    local scripts=()
    while IFS= read -r f; do
        [ -f "${DOTFILES_DIR}/$f" ] || continue
        head -1 "${DOTFILES_DIR}/$f" 2>/dev/null | grep -qE '^#!.*\b(sh|bash)\b' &&
            scripts+=("${DOTFILES_DIR}/$f")
    done < <(git -C "${DOTFILES_DIR}" ls-files)

    [ "${#scripts[@]}" -gt 0 ]
    run shellcheck -S error "${scripts[@]}"
    [ "$status" -eq 0 ]
}
