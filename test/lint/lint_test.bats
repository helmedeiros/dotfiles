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
