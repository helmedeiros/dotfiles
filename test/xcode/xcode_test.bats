#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

DOTFILES="${BATS_TEST_DIRNAME}/../.."
INSTALL="${DOTFILES}/xcode/install.sh"
BREWFILE="${DOTFILES}/Brewfile"
XCODE_MAS_ID="497799835"

setup() {
  TEST_DIR="$(mktemp -d)"
  mkdir -p "${TEST_DIR}/bin"
  PATH="${TEST_DIR}/bin:${PATH}"
}

teardown() {
  rm -rf "${TEST_DIR}"
}

# Stubs standing in for a machine that already has Xcode activated, so the
# script can run end to end without sudo or a real 15 GB install.
an_activated_xcode() {
  mkdir -p "${TEST_DIR}/Xcode.app/Contents/Developer"

  cat > "${TEST_DIR}/bin/xcode-select" <<EOF
#!/bin/sh
[ "\$1" = "-p" ] && echo "${TEST_DIR}/Xcode.app/Contents/Developer"
EOF

  cat > "${TEST_DIR}/bin/xcodebuild" <<'EOF'
#!/bin/sh
case "$1" in
  -version) echo "Xcode 26.6" ;;
  -checkFirstLaunchStatus) exit 0 ;;
esac
EOF

  # Any sudo call means a guard failed to notice work was already done.
  cat > "${TEST_DIR}/bin/sudo" <<EOF
#!/bin/sh
echo "UNEXPECTED SUDO: \$*" >> "${TEST_DIR}/sudo.log"
EOF

  chmod +x "${TEST_DIR}/bin/xcode-select" "${TEST_DIR}/bin/xcodebuild" "${TEST_DIR}/bin/sudo"
}

# --- Wiring: dot must have something to install ---

@test "Brewfile declares the Xcode mas entry, uncommented" {
  grep -qE "^mas 'Xcode', id: ${XCODE_MAS_ID}" "${BREWFILE}"
}

@test "install.sh runs after brew bundle, so it never installs the app itself" {
  # brew bundle owns the install; this script only activates the toolchain.
  run ! grep -qE '^[[:space:]]*mas install' "${INSTALL}"
}

# --- Behaviour ---

@test "skips cleanly when Xcode is absent, without failing dot" {
  run env XCODE_APP="${TEST_DIR}/nonexistent.app" sh "${INSTALL}"

  [ "$status" -eq 0 ]
  [[ "$output" == *"Xcode is not installed"* ]]
  [[ "$output" == *"${XCODE_MAS_ID}"* ]]
}

@test "is idempotent: an already-activated Xcode needs no privileged calls" {
  an_activated_xcode

  run env XCODE_APP="${TEST_DIR}/Xcode.app" sh "${INSTALL}"

  [ "$status" -eq 0 ]
  [[ "$output" == *"Xcode ready"* ]]
  [ ! -f "${TEST_DIR}/sudo.log" ]
}

@test "selects the developer dir when the Command Line Tools are still active" {
  an_activated_xcode
  # Report the CLT path, the state that makes xcodebuild fail in practice.
  cat > "${TEST_DIR}/bin/xcode-select" <<'EOF'
#!/bin/sh
[ "$1" = "-p" ] && echo "/Library/Developer/CommandLineTools"
EOF
  chmod +x "${TEST_DIR}/bin/xcode-select"

  run env XCODE_APP="${TEST_DIR}/Xcode.app" sh "${INSTALL}"

  [ "$status" -eq 0 ]
  [[ "$output" == *"Selecting"* ]]
  grep -q "xcode-select -s ${TEST_DIR}/Xcode.app/Contents/Developer" "${TEST_DIR}/sudo.log"
}

@test "does not hang on a sudo password prompt when stdin is not a terminal" {
  an_activated_xcode
  cat > "${TEST_DIR}/bin/xcode-select" <<'EOF'
#!/bin/sh
[ "$1" = "-p" ] && echo "/Library/Developer/CommandLineTools"
EOF
  # sudo -n fails (no cached credentials) and stdin is not a tty, so the
  # script must report and move on rather than block bin/dot forever.
  cat > "${TEST_DIR}/bin/sudo" <<'EOF'
#!/bin/sh
[ "$1" = "-n" ] && exit 1
echo "BLOCKED WAITING FOR PASSWORD" >&2
exit 1
EOF
  chmod +x "${TEST_DIR}/bin/xcode-select" "${TEST_DIR}/bin/sudo"

  run env XCODE_APP="${TEST_DIR}/Xcode.app" sh "${INSTALL}" < /dev/null

  [ "$status" -eq 0 ]
  [[ "$output" == *"Needs sudo, skipping"* ]]
  [[ "$output" != *"BLOCKED WAITING FOR PASSWORD"* ]]
}
