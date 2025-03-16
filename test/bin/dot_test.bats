#!/usr/bin/env bats

# Path to the script being tested
DOT_SCRIPT="${BATS_TEST_DIRNAME}/../../bin/dot"

# Load the Object Mother
load "../mothers/test_mother.sh"

# Setup function that runs before each test
setup() {
  # Create a temporary directory for test files
  TEST_DIR="$(mktemp -d)"

  # Create a modified version of the dot script that uses our mocked environment
  MOCK_SCRIPT="${TEST_DIR}/dot"
  cp "${DOT_SCRIPT}" "${MOCK_SCRIPT}"
  chmod +x "${MOCK_SCRIPT}"

  # Use the modified script for testing
  DOT_SCRIPT="${MOCK_SCRIPT}"

  # Create a mock editor that just echoes its arguments
  mkdir -p "${TEST_DIR}/bin"
  cat > "${TEST_DIR}/bin/mock-editor" << 'EOL'
#!/bin/sh
echo "Would edit: $@"
exit 0
EOL
  chmod +x "${TEST_DIR}/bin/mock-editor"

  # Set the mock editor as the EDITOR
  export EDITOR="${TEST_DIR}/bin/mock-editor"

  # Add the mock bin directory to the PATH (at the beginning to take precedence)
  export PATH="${TEST_DIR}/bin:${PATH}"
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
