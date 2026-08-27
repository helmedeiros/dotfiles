#!/usr/bin/env bats

# Path to the script being tested
# `run !` needs 1.5.0; a bare `!` does not fail a bats test.
bats_require_minimum_version 1.5.0

DOT_SCRIPT="${BATS_TEST_DIRNAME}/../../bin/dot"

# Load the Object Mother
load "../mothers/test_mother.sh"
load "../mothers/brew_mother.sh"
load "../mothers/npm_mother.sh"
load "../mothers/macos_mother.sh"
load "../mothers/mas_mother.sh"
load "../mothers/editor_mother.sh"
load "../mothers/script_mother.sh"

# Setup function that runs before each test
setup() {
  # Create a temporary directory for test files
  TEST_DIR="$(mktemp -d)"

  # Set up environment variables
  export HOME="${TEST_DIR}"
  export ZSH="${HOME}/.dotfiles"

  # Create dotfiles directory structure
  mkdir -p "${ZSH}"/{homebrew,macos,node,script}

  # Create mock commands directory
  mkdir -p "${TEST_DIR}/bin"

  # Create mock brew command
  create_mock_brew "${TEST_DIR}/bin/brew"

  # Create Mac App Store (mas) mocks
  create_dot_mas_mocks "${TEST_DIR}"

  # Create npm-related mocks
  create_dot_npm_mocks "${TEST_DIR}"

  # Create macOS-related mocks
  create_dot_macos_mocks "${TEST_DIR}"

  # Create editor-related mocks
  create_dot_editor_mocks "${TEST_DIR}"

  # Create script-related mocks
  create_dot_script_mocks "${TEST_DIR}"

  # Add mock commands to PATH (at the beginning to take precedence)
  export PATH="${TEST_DIR}/bin:${PATH}"

  # Create a modified version of the script that uses our mocked environment
  MOCK_SCRIPT="${TEST_DIR}/dot"
  cp "${DOT_SCRIPT}" "${MOCK_SCRIPT}"
  chmod +x "${MOCK_SCRIPT}"

  # Use the modified script for testing
  DOT_SCRIPT="${MOCK_SCRIPT}"
}

# Teardown function that runs after each test
teardown() {
  # Clean up the temporary directory
  rm -rf "${TEST_DIR}"
}

# Test that the script exists and is executable
@test "dot script exists and is executable" {
  [ -f "$DOT_SCRIPT" ]
  [ -x "$DOT_SCRIPT" ]
}

# Trust has to precede update/upgrade: `brew upgrade` skips packages from
# untrusted taps, so trusting afterwards leaves them silently un-upgraded.
@test "dot trusts Brewfile taps before running brew update and upgrade" {
  trust_line="$(grep -n '› brew trust' "$DOT_SCRIPT" | cut -d: -f1)"
  update_line="$(grep -n '› brew update' "$DOT_SCRIPT" | cut -d: -f1)"
  upgrade_line="$(grep -n '› brew upgrade' "$DOT_SCRIPT" | cut -d: -f1)"

  [ -n "$trust_line" ]
  [ "$trust_line" -lt "$update_line" ]
  [ "$trust_line" -lt "$upgrade_line" ]
}

# `brew trust <name>` resolves the argument ambiguously and can match an
# unrelated tap with the same repo basename; --tap pins the interpretation.
@test "dot trusts taps with an explicit --tap flag" {
  grep -q 'brew trust --tap "\$tap"' "$DOT_SCRIPT"
}

# Every tap the machine relies on must be declared, since the trust loop reads
# its list from the Brewfile and nowhere else.
@test "Brewfile declares a tap for every installed non-core formula" {
  if ! command -v brew &> /dev/null; then
    skip "brew not installed"
  fi

  brewfile="${BATS_TEST_DIRNAME}/../../Brewfile"
  declared="$(grep -E "^tap [\"']" "$brewfile" \
    | sed -E "s/^tap [\"']([^\"']+)[\"'].*/\1/" \
    | sed -E 's|/homebrew-|/|')"

  # Resolve each formula's CURRENT tap rather than the name recorded at install
  # time: Homebrew follows GitHub redirects when a tap's owner renames their
  # account, so 'brew list --full-name' can keep reporting a name that no
  # longer exists (koekeishiya/formulae -> asmvik/formulae).
  while IFS= read -r tap; do
    [ -z "$tap" ] && continue
    echo "$declared" | grep -qx "$tap" || {
      echo "installed formula comes from undeclared tap $tap"
      false
    }
  done < <(brew info --json=v2 --installed 2>/dev/null \
    | jq -r '.formulae[] | select(.tap != null and .tap != "homebrew/core") | .tap' \
    | sort -u)
}

# Test help option with short flag
@test "dot -h displays help message" {
  run "$DOT_SCRIPT" -h
  [ "$status" -eq 0 ]
  [[ "${output}" == *"Usage: dot [options]"* ]]
  [[ "${output}" =~ "-e, --edit" ]]
  [[ "${output}" =~ "-h, --help" ]]
}

# Test help option with long flag
@test "dot --help displays help message" {
  run "$DOT_SCRIPT" --help
  [ "$status" -eq 0 ]
  [[ "${output}" == *"Usage: dot [options]"* ]]
  [[ "${output}" =~ "-e, --edit" ]]
  [[ "${output}" =~ "-h, --help" ]]
}

# Test edit option with short flag
@test "dot -e attempts to open dotfiles directory" {
  run "$DOT_SCRIPT" -e
  [ "$status" -eq 0 ]
  [[ "${output}" =~ "Would edit:" ]]
}

# Test edit option with long flag
@test "dot --edit attempts to open dotfiles directory" {
  run "$DOT_SCRIPT" --edit
  [ "$status" -eq 0 ]
  [[ "${output}" =~ "Would edit:" ]]
}

# Test invalid option
@test "dot with invalid option shows error and help" {
  run "$DOT_SCRIPT" --invalid
  [ "$status" -eq 0 ]
  [[ "${output}" =~ "Invalid option: --invalid" ]]
  [[ "${output}" == *"Usage: dot [options]"* ]]
}

# Test that Homebrew installation is attempted
@test "dot script attempts to install Homebrew" {
  run "$DOT_SCRIPT"

  [ "$status" -eq 0 ]
  [ -s "$MOCK_INSTALL_LOG" ]  # File should not be empty
}

# Test that Homebrew is updated
@test "dot script updates Homebrew" {
  run "$DOT_SCRIPT"

  [ "$status" -eq 0 ]
  [[ "${output}" =~ "› brew update" ]]
  grep "update" "$MOCK_BREW_LOG"
}

# Test that outdated packages are upgraded
@test "dot script upgrades outdated packages" {
  run "$DOT_SCRIPT"

  [ "$status" -eq 0 ]
  [[ "${output}" =~ "› brew upgrade" ]]
  grep "upgrade" "$MOCK_BREW_LOG"
}

# Test that Brewfile packages are installed
@test "dot script installs packages from Brewfile" {
  run "$DOT_SCRIPT"

  [ "$status" -eq 0 ]
  [[ "${output}" =~ "› brew bundle" ]]
  grep "bundle install --file=" "$MOCK_BREW_LOG"
}

# Test error handling when Brewfile is missing
@test "dot script handles missing Brewfile gracefully" {
  rm "${TEST_DIR}/Brewfile"
  run "$DOT_SCRIPT"

  [ "$status" -eq 0 ]
  [[ "${output}" =~ "› brew bundle" ]]
}

# Test error handling when Homebrew installation fails
@test "dot script exits when Homebrew installation fails" {
  # Make the install script fail but still log
  cat > "${ZSH}/homebrew/install.sh" << 'EOL'
#!/bin/sh
echo "$0" >> "$(dirname "$0")/../../install.log"
exit 1
EOL

  run "$DOT_SCRIPT"
  [ "$status" -eq 1 ]  # Script should exit with error when Homebrew install fails
  [ -s "$MOCK_INSTALL_LOG" ]  # File should not be empty
}

# The npm block was over half of bin/dot and duplicated bin/check-updates.
@test "dot delegates Node updates to node/update.sh" {
  grep -q 'node/update.sh' "$DOT_SCRIPT"
  # None of the extracted body may remain inline.
  run ! grep -q 'Checking for outdated global npm packages' "$DOT_SCRIPT"
}

# A warning printed above a "completed successfully" banner is not a report.
@test "dot does not claim success when post-install scripts fail" {
  cat > "${ZSH}/script/install" <<'EOL'
#!/bin/sh
echo "$0" >> "$(dirname "$0")/../../script_install.log"
exit 1
EOL
  chmod +x "${ZSH}/script/install"

  run "$DOT_SCRIPT"

  [ "$status" -ne 0 ]
  [[ "${output}" == *"WITH FAILURES"* ]]
  [[ "${output}" != *"completed successfully"* ]]
}

@test "dot still reports success when everything passes" {
  run "$DOT_SCRIPT"

  [ "$status" -eq 0 ]
  [[ "${output}" == *"completed successfully"* ]]
}
