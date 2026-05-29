#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

SCRIPT="${BATS_TEST_DIRNAME}/../../bin/claude-bootstrap"

setup() {
    TMP_HOME="$(mktemp -d)"
    FAKE_BIN="${TMP_HOME}/fake-bin"
    REPO="${TMP_HOME}/repo"
    mkdir -p "${FAKE_BIN}" "${REPO}"

    # Fake bd records every invocation and simulates expected side effects.
    cat > "${FAKE_BIN}/bd" <<'EOF'
#!/usr/bin/env bash
log="${FAKE_BD_LOG:?FAKE_BD_LOG must be set}"
echo "$*" >> "${log}"
case "$1" in
    init)
        mkdir -p .beads
        echo "init-marker" > .beads/db.sqlite
        ;;
    setup)
        if [ "$2" = "claude" ]; then
            mkdir -p .claude
            printf '%s\n' '{"hooks":{"SessionStart":["bd prime"]}}' > .claude/settings.json
        fi
        ;;
    *)
        echo "fake bd: unknown command $1" >&2
        exit 99
        ;;
esac
EOF
    chmod +x "${FAKE_BIN}/bd"

    export FAKE_BD_LOG="${TMP_HOME}/bd-calls.log"
    : > "${FAKE_BD_LOG}"
    export PATH="${FAKE_BIN}:${PATH}"
}

teardown() {
    rm -rf "${TMP_HOME}"
}

# --- Static checks ---

@test "claude-bootstrap exists and is executable" {
    [ -x "${SCRIPT}" ]
}

@test "claude-bootstrap --help exits 0 and shows usage" {
    run "${SCRIPT}" --help
    [ "${status}" -eq 0 ]
    [[ "${output}" == *"Usage: claude-bootstrap"* ]]
    [[ "${output}" == *"--with-claude-md"* ]]
}

@test "claude-bootstrap -h is the same as --help" {
    run "${SCRIPT}" -h
    [ "${status}" -eq 0 ]
    [[ "${output}" == *"Usage: claude-bootstrap"* ]]
}

@test "claude-bootstrap rejects unknown arguments with exit 2" {
    run "${SCRIPT}" --bogus
    [ "${status}" -eq 2 ]
    [[ "${output}" == *"unknown argument"* ]]
}

# --- Error when bd is missing ---

@test "claude-bootstrap exits 1 with clear error when bd is not on PATH" {
    # Use a minimal PATH that excludes anywhere a real bd might live (e.g.
    # /opt/homebrew/bin) so the test works on machines with beads installed.
    cd "${REPO}"
    PATH="/usr/bin:/bin" run "${SCRIPT}"
    [ "${status}" -eq 1 ]
    [[ "${output}" == *"'bd' (beads CLI) not found"* ]]
}

# --- Happy path ---

@test "claude-bootstrap runs bd init and bd setup claude in a fresh repo" {
    cd "${REPO}"
    run "${SCRIPT}"
    [ "${status}" -eq 0 ]

    grep -q '^init$' "${FAKE_BD_LOG}"
    grep -q '^setup claude$' "${FAKE_BD_LOG}"

    [ -d "${REPO}/.beads" ]
    [ -f "${REPO}/.claude/settings.json" ]
    grep -q 'SessionStart' "${REPO}/.claude/settings.json"
}

@test "claude-bootstrap skips bd init when .beads already exists" {
    cd "${REPO}"
    mkdir -p .beads
    echo "preexisting" > .beads/marker

    run "${SCRIPT}"
    [ "${status}" -eq 0 ]

    # bd init should NOT have been called, but bd setup claude should.
    ! grep -q '^init$' "${FAKE_BD_LOG}"
    grep -q '^setup claude$' "${FAKE_BD_LOG}"

    # Existing .beads/ untouched.
    [ "$(cat .beads/marker)" = "preexisting" ]
}

@test "claude-bootstrap is idempotent on a second run" {
    cd "${REPO}"
    "${SCRIPT}"
    : > "${FAKE_BD_LOG}"

    run "${SCRIPT}"
    [ "${status}" -eq 0 ]

    # On the second run, .beads exists so init is skipped.
    ! grep -q '^init$' "${FAKE_BD_LOG}"
    grep -q '^setup claude$' "${FAKE_BD_LOG}"
}

# --- --with-claude-md ---

@test "claude-bootstrap --with-claude-md writes CLAUDE.md template" {
    cd "${REPO}"
    run "${SCRIPT}" --with-claude-md
    [ "${status}" -eq 0 ]

    [ -f "${REPO}/CLAUDE.md" ]
    grep -q 'Project notes for Claude Code' "${REPO}/CLAUDE.md"
    grep -q 'beads' "${REPO}/CLAUDE.md"
}

@test "claude-bootstrap --with-claude-md does NOT overwrite an existing CLAUDE.md" {
    cd "${REPO}"
    echo "user content" > CLAUDE.md

    run "${SCRIPT}" --with-claude-md
    [ "${status}" -eq 0 ]

    [ "$(cat "${REPO}/CLAUDE.md")" = "user content" ]
}

@test "claude-bootstrap without --with-claude-md does not create CLAUDE.md" {
    cd "${REPO}"
    run "${SCRIPT}"
    [ "${status}" -eq 0 ]

    [ ! -f "${REPO}/CLAUDE.md" ]
}
