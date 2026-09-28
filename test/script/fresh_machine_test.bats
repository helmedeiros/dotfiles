#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

DOTFILES="${BATS_TEST_DIRNAME}/../.."
EXCEPTIONS="${DOTFILES}/test/fresh-machine-exceptions.txt"

setup_file() {
    export SANDBOX_REPO="${BATS_FILE_TMPDIR}/repo"
    mkdir -p "${SANDBOX_REPO}"
    ( cd "${BATS_TEST_DIRNAME}/../.." && tar --exclude=.git -cf - . ) \
        | ( cd "${SANDBOX_REPO}" && tar -xf - )

    export REPO_STATE_BEFORE="${BATS_FILE_TMPDIR}/state-before"
    git -C "${BATS_TEST_DIRNAME}/../.." status --porcelain > "${REPO_STATE_BEFORE}"
}

NEUTRALISED_COMMANDS=(
    sudo defaults osascript killall chflags chsh launchctl softwareupdate
    installer mas open ditto plutil scutil systemsetup spctl dscl hdiutil
    xcode-select xcodebuild curl wget git python python3
)

assert_sandboxed() {
    [ -n "${TEST_DIR}" ]
    [ "${BARE_HOME}" != "${REAL_HOME}" ]
    case "${BARE_HOME}" in
        "${TEST_DIR}"*) ;;
        *) echo "HOME escaped the sandbox: ${BARE_HOME}" >&2; return 1 ;;
    esac
}

setup() {
    REAL_HOME="${HOME}"
    TEST_DIR="$(mktemp -d)"
    BARE_HOME="${TEST_DIR}/home"
    STUB_BIN="${TEST_DIR}/bin"
    PROBE_LOG="${TEST_DIR}/invoked.log"
    mkdir -p "${BARE_HOME}" "${STUB_BIN}"
    : > "${PROBE_LOG}"

    local command
    for command in "${NEUTRALISED_COMMANDS[@]}"; do
        cat > "${STUB_BIN}/${command}" <<EOL
#!/bin/sh
printf '%s %s\n' "${command}" "\$*" >> "${PROBE_LOG}"
exit 0
EOL
        chmod +x "${STUB_BIN}/${command}"
    done

    assert_sandboxed
}

teardown() {
    [ -n "${TEST_DIR}" ] && rm -rf "${TEST_DIR}"
}

excepted_topics() {
    grep -vE '^[[:space:]]*(#|$)' "${EXCEPTIONS}"
}

topic_installers() {
    (cd "${DOTFILES}" && git ls-files '*/install.sh' | sort)
}

topic_of() {
    printf '%s' "${1%%/*}"
}

run_on_bare_machine() {
    local installer="$1"
    rm -rf "${BARE_HOME}"
    mkdir -p "${BARE_HOME}"
    perl -e 'alarm shift @ARGV; exec @ARGV or die' 30 \
        env -i \
        HOME="${BARE_HOME}" \
        PROBE_LOG="${PROBE_LOG}" \
        PATH="${STUB_BIN}:/usr/bin:/bin" \
        SHELL=/bin/zsh \
        TERM=dumb \
        CURSOR_APP="${BARE_HOME}/Applications/Cursor.app" \
        ROBO3T_APP="${BARE_HOME}/Applications/Robo 3T.app" \
        VIMAC_APP="${BARE_HOME}/Applications/Vimac.app" \
        XCODE_APP="${BARE_HOME}/Applications/Xcode.app" \
        VISCOSITY_APP="${BARE_HOME}/Applications/Viscosity.app" \
        VISCOSITY_SCRIPTS="${BARE_HOME}/Library/ViscosityScripts" \
        "${SANDBOX_REPO}/${installer}" </dev/null 2>&1
}

provision_topic() {
    local topic="$1"

    case "$topic" in
        hoster)
            mkdir -p "${BARE_HOME}/.hoster"
            printf '#!/bin/sh\n' > "${BARE_HOME}/.hoster/hoster"
            chmod +x "${BARE_HOME}/.hoster/hoster"
            ;;
        zsh-completion-generator)
            mkdir -p "${BARE_HOME}/.zsh-completion-generator"
            printf 'gencomp() { return 0; }\n' \
                > "${BARE_HOME}/.zsh-completion-generator/zsh-completion-generator.plugin.zsh"
            ;;
        kcc)
            mkdir -p "${BARE_HOME}/.local/bin" "${BARE_HOME}/.local/share/kcc/venv"
            printf '#!/bin/sh\n' > "${BARE_HOME}/.local/bin/kcc-c2e"
            chmod +x "${BARE_HOME}/.local/bin/kcc-c2e"
            ;;
        vimac)
            mkdir -p "${BARE_HOME}/Applications/Vimac.app/Contents"
            ;;
        sdkman)
            mkdir -p "${BARE_HOME}/.sdkman/bin"
            cat > "${BARE_HOME}/.sdkman/bin/sdkman-init.sh" <<'EOL'
sdk() {
    case "$1" in
        current) echo "Using java version 21-tem" ;;
    esac
    return 0
}
EOL
            ;;
        vault)
            cat > "${STUB_BIN}/vault" <<'EOL'
#!/bin/sh
echo "Vault v2.1.1 (stub)"
EOL
            chmod +x "${STUB_BIN}/vault"
            ;;
        tools)
            printf '#!/bin/sh\necho aider stub\n' > "${STUB_BIN}/aider"
            chmod +x "${STUB_BIN}/aider"
            ;;
        *)
            return 1
            ;;
    esac
}

run_provisioned() {
    local installer="$1" topic="$2"
    rm -rf "${BARE_HOME}"
    mkdir -p "${BARE_HOME}"
    provision_topic "$topic" || return 2
    perl -e 'alarm shift @ARGV; exec @ARGV or die' 30 \
        env -i \
        HOME="${BARE_HOME}" \
        PROBE_LOG="${PROBE_LOG}" \
        PATH="${STUB_BIN}:/usr/bin:/bin" \
        SHELL=/bin/zsh \
        TERM=dumb \
        CURSOR_APP="${BARE_HOME}/Applications/Cursor.app" \
        ROBO3T_APP="${BARE_HOME}/Applications/Robo 3T.app" \
        VIMAC_APP="${BARE_HOME}/Applications/Vimac.app" \
        XCODE_APP="${BARE_HOME}/Applications/Xcode.app" \
        VISCOSITY_APP="${BARE_HOME}/Applications/Viscosity.app" \
        VISCOSITY_SCRIPTS="${BARE_HOME}/Library/ViscosityScripts" \
        "${SANDBOX_REPO}/${installer}" </dev/null 2>&1
}

@test "installers run against a copy, never the working tree" {
    [ -n "${SANDBOX_REPO}" ]
    [ -d "${SANDBOX_REPO}" ]
    case "${SANDBOX_REPO}" in
        "${BATS_FILE_TMPDIR}"*) ;;
        *) echo "sandbox repo escaped: ${SANDBOX_REPO}" >&2; return 1 ;;
    esac
    [ ! -d "${SANDBOX_REPO}/.git" ]
}

@test "the exceptions list is only topics that exist" {
    local topic
    while IFS= read -r topic; do
        [ -n "$topic" ] || continue
        [ -d "${DOTFILES}/${topic}" ] || { echo "no such topic: ${topic}" >&2; return 1; }
    done <<< "$(excepted_topics)"
}

@test "every installer skips rather than fails on a bare machine" {
    local failures=""
    local installer topic output status

    while IFS= read -r installer; do
        [ -n "$installer" ] || continue
        topic="$(topic_of "$installer")"
        grep -qxF "$topic" <<< "$(excepted_topics)" && continue

        output="$(run_on_bare_machine "$installer")" && status=0 || status=$?
        if [ -e "${BARE_HOME}/.dot-secrets" ]; then
            echo "${installer} created a .dot-secrets on a bare machine" >&2
            return 1
        fi
        if [ "$status" -ne 0 ]; then
            failures="${failures}  ${installer} exited ${status}: $(tail -1 <<< "$output")
"
        fi
    done <<< "$(topic_installers)"

    if [ -n "$failures" ]; then
        echo "installers that failed instead of skipping:" >&2
        printf '%s' "$failures" >&2
        return 1
    fi
}

@test "no excepted topic has quietly become compliant" {
    local topic status
    while IFS= read -r topic; do
        [ -n "$topic" ] || continue
        run_on_bare_machine "${topic}/install.sh" >/dev/null 2>&1 && status=0 || status=$?
        if [ "$status" -eq 0 ]; then
            echo "${topic} skips cleanly now — remove it from ${EXCEPTIONS##*/}" >&2
            return 1
        fi
    done <<< "$(excepted_topics)"
}

@test "running the installers left the working tree untouched" {
    local after="${BATS_FILE_TMPDIR}/state-after"
    git -C "${DOTFILES}" status --porcelain > "${after}"
    diff "${REPO_STATE_BEFORE}" "${after}"
}

@test "a topic that cannot skip on a bare machine still exits 0 once provisioned" {
    local failures="" topic output status

    local installer
    while IFS= read -r topic; do
        [ -n "$topic" ] || continue
        installer="$(topic_installers | grep -m1 "^${topic}/")"
        [ -n "$installer" ] || { failures="${failures}  ${topic} has no installer
"; continue; }

        output="$(run_provisioned "$installer" "$topic")" && status=0 || status=$?
        if [ "$status" -eq 2 ]; then
            failures="${failures}  ${topic} has no provisioned fixture
"
            continue
        fi
        if [ "$status" -ne 0 ]; then
            failures="${failures}  ${topic} exited ${status}: $(tail -1 <<< "$output")
"
        fi
    done <<< "$(excepted_topics)"

    if [ -n "$failures" ]; then
        echo "provisioned topics that did not exit 0:" >&2
        printf '%s' "$failures" >&2
        return 1
    fi
}
