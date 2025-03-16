#!/usr/bin/env bats

# Path to the script being tested
DOT_SCRIPT="${BATS_TEST_DIRNAME}/../../bin/dot"

# Load the Object Mother
load "../mothers/test_mother.sh"
load "../mothers/brew_mother.sh"
load "../mothers/npm_mother.sh"

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

  # Create a mock editor that just echoes its arguments
  cat > "${TEST_DIR}/bin/mock-editor" << 'EOL'
#!/bin/sh
echo "Would edit: $@"
exit 0
EOL
  chmod +x "${TEST_DIR}/bin/mock-editor"

  # Create mock brew command
  create_mock_brew "${TEST_DIR}/bin/brew"

  # Create mock mas command
  cat > "${TEST_DIR}/bin/mas" << 'EOL'
#!/bin/sh
echo "$0 $*" >> "$(dirname "$0")/../mas.log"
exit 0
EOL
  chmod +x "${TEST_DIR}/bin/mas"

  # Create npm-related mocks
  create_dot_npm_mocks "${TEST_DIR}"

  # Set the mock editor as the EDITOR
  export EDITOR="${TEST_DIR}/bin/mock-editor"

  # Add mock commands to PATH (at the beginning to take precedence)
  export PATH="${TEST_DIR}/bin:${PATH}"

  # Create mock install.sh script that just logs the call
  cat > "${ZSH}/homebrew/install.sh" << 'EOL'
#!/bin/sh
echo "$0" >> "$(dirname "$0")/../../install.log"
exit 0
EOL
  chmod +x "${ZSH}/homebrew/install.sh"

  # Create mock set-defaults.sh script
  cat > "${ZSH}/macos/set-defaults.sh" << 'EOL'
#!/bin/sh
echo "$0" >> "$(dirname "$0")/../../macos.log"
exit 0
EOL
  chmod +x "${ZSH}/macos/set-defaults.sh"

  # Create mock node/path.zsh script
  mkdir -p "${ZSH}/node"
  cat > "${ZSH}/node/path.zsh" << 'EOL'
#!/bin/sh
echo "Mock NVM configuration loaded"
exit 0
EOL
  chmod +x "${ZSH}/node/path.zsh"

  # Create mock node/install.sh script
  cat > "${ZSH}/node/install.sh" << 'EOL'
#!/bin/sh
echo "$0" >> "$(dirname "$0")/../../node_install.log"
exit 0
EOL
  chmod +x "${ZSH}/node/install.sh"

  # Create mock script/install script
  mkdir -p "${ZSH}/script"
  cat > "${ZSH}/script/install" << 'EOL'
#!/bin/sh
echo "$0" >> "$(dirname "$0")/../../script_install.log"
exit 0
EOL
  chmod +x "${ZSH}/script/install"

  # Create mock Brewfile
  echo "# Brewfile for testing" > "${TEST_DIR}/Brewfile"

  # Initialize the mock command logs
  MOCK_BREW_LOG="${TEST_DIR}/brew.log"
  MOCK_MAS_LOG="${TEST_DIR}/mas.log"
  MOCK_INSTALL_LOG="${TEST_DIR}/install.log"
  MOCK_MACOS_LOG="${TEST_DIR}/macos.log"
  MOCK_NODE_LOG="${TEST_DIR}/node.log"
  MOCK_NPM_LOG="${TEST_DIR}/npm.log"
  MOCK_NVM_LOG="${TEST_DIR}/nvm.log"
  MOCK_NODE_INSTALL_LOG="${TEST_DIR}/node_install.log"
  MOCK_SCRIPT_INSTALL_LOG="${TEST_DIR}/script_install.log"
  touch "$MOCK_BREW_LOG" "$MOCK_MAS_LOG" "$MOCK_INSTALL_LOG" "$MOCK_MACOS_LOG" \
        "$MOCK_NODE_LOG" "$MOCK_NPM_LOG" "$MOCK_NVM_LOG" "$MOCK_NODE_INSTALL_LOG" \
        "$MOCK_SCRIPT_INSTALL_LOG"

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

# Test help option with short flag
@test "dot -h displays help message" {
  run "$DOT_SCRIPT" -h
  [ "$status" -eq 0 ]
  [[ "${output}" =~ "Usage: dot [options]" ]]
  [[ "${output}" =~ "-e, --edit" ]]
  [[ "${output}" =~ "-h, --help" ]]
}

# Test help option with long flag
@test "dot --help displays help message" {
  run "$DOT_SCRIPT" --help
  [ "$status" -eq 0 ]
  [[ "${output}" =~ "Usage: dot [options]" ]]
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
  [[ "${output}" =~ "Usage: dot [options]" ]]
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
