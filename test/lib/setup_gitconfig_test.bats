#!/usr/bin/env bats
#
# Integration test for script/bootstrap setup_gitconfig — exercises the full
# flow against a controlled DOTFILES_ROOT + DOT_SECRETS_ROOT, with the
# script's status-print helpers (info/user/success/fail) stubbed out.

bats_require_minimum_version 1.5.0

DOTFILES="${BATS_TEST_DIRNAME}/../.."

setup() {
    TEST_ROOT="$(mktemp -d)"
    export DOTFILES_ROOT="${TEST_ROOT}/dotfiles"
    export DOT_SECRETS_ROOT="${TEST_ROOT}/.dot-secrets"
    mkdir -p "${DOTFILES_ROOT}/git" "${DOTFILES_ROOT}/lib" "${DOT_SECRETS_ROOT}/git"

    # Copy just the files setup_gitconfig touches.
    cp "${DOTFILES}/git/gitconfig.symlink.example" "${DOTFILES_ROOT}/git/"
    cp "${DOTFILES}/lib/dot-secrets.sh" "${DOTFILES_ROOT}/lib/"
    cp "${DOTFILES}/lib/git-identity.sh" "${DOTFILES_ROOT}/lib/"

    # Stub status helpers so bootstrap's setup_gitconfig has them.
    info()    { :; }
    user()    { :; }
    success() { :; }
    fail()    { echo "fail: $*" >&2; return 1; }
    export -f info user success fail

    # Pull setup_gitconfig out of script/bootstrap so we can call it directly.
    # The function is self-contained — it reads no global outside what we set up.
    eval "$(sed -n '/^setup_gitconfig () {/,/^}/p' "${DOTFILES}/script/bootstrap")"
}

teardown() {
    rm -rf "${TEST_ROOT}"
    unset GIT_AUTHOR_NAME GIT_AUTHOR_EMAIL
}

@test "setup_gitconfig uses .dot-secrets identity when available" {
    cat > "${DOT_SECRETS_ROOT}/git/identity.sh" <<'EOF'
GIT_AUTHOR_NAME="Jane Doe"
GIT_AUTHOR_EMAIL="12345+jane@users.noreply.github.com"
EOF

    cd "${DOTFILES_ROOT}"
    setup_gitconfig

    [ -f "${DOTFILES_ROOT}/git/gitconfig.symlink" ]
    grep -q "name = Jane Doe" "${DOTFILES_ROOT}/git/gitconfig.symlink"
    grep -q "email = 12345+jane@users.noreply.github.com" "${DOTFILES_ROOT}/git/gitconfig.symlink"
}

@test "setup_gitconfig does not overwrite an existing gitconfig.symlink" {
    cat > "${DOTFILES_ROOT}/git/gitconfig.symlink" <<'EOF'
[user]
    name = preexisting
EOF

    cat > "${DOT_SECRETS_ROOT}/git/identity.sh" <<'EOF'
GIT_AUTHOR_NAME="Should Not Appear"
GIT_AUTHOR_EMAIL="nope@example.test"
EOF

    cd "${DOTFILES_ROOT}"
    setup_gitconfig

    [ "$(cat "${DOTFILES_ROOT}/git/gitconfig.symlink")" = "[user]
    name = preexisting" ]
}

@test "setup_gitconfig credential helper matches the platform" {
    cat > "${DOT_SECRETS_ROOT}/git/identity.sh" <<'EOF'
GIT_AUTHOR_NAME="Jane"
GIT_AUTHOR_EMAIL="jane@example.test"
EOF

    cd "${DOTFILES_ROOT}"
    setup_gitconfig

    if [ "$(uname -s)" = "Darwin" ]; then
        grep -q "helper = osxkeychain" "${DOTFILES_ROOT}/git/gitconfig.symlink"
    else
        grep -q "helper = cache" "${DOTFILES_ROOT}/git/gitconfig.symlink"
    fi
}
