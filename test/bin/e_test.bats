#!/usr/bin/env bats

# Path to the script being tested
E_SCRIPT="${BATS_TEST_DIRNAME}/../../bin/e"

# Load the Object Mother
load "../mothers/test_mother.sh"
load "../mothers/editor_mother.sh"

# Setup function that runs before each test
setup() {
  # Create a temporary directory for test files
  TEST_DIR="$(mktemp -d)"

  # Set up environment variables
  export HOME="${TEST_DIR}"

  # Create editor-related mocks
  create_dot_editor_mocks "${TEST_DIR}"

  # Create a modified version of the script that uses our mocked environment
  MOCK_SCRIPT="${TEST_DIR}/e"
  cp "${E_SCRIPT}" "${MOCK_SCRIPT}"
  chmod +x "${MOCK_SCRIPT}"

  # Use the modified script for testing
  E_SCRIPT="${MOCK_SCRIPT}"
}

# Teardown function that runs after each test
teardown() {
  # Clean up the temporary directory
  rm -rf "${TEST_DIR}"
}

# Test script existence and executability
@test "e script exists and is executable" {
  [ -f "${E_SCRIPT}" ]
  [ -x "${E_SCRIPT}" ]
}

# Test opening current directory
@test "e opens current directory when no argument is provided" {
  run "${E_SCRIPT}"
  [ "$status" -eq 0 ]
  [ "$output" = "Would edit: ." ]
}

# Test opening specified directory
@test "e opens specified directory when argument is provided" {
  local test_dir="${TEST_DIR}/test_dir"
  mkdir -p "${test_dir}"

  run "${E_SCRIPT}" "${test_dir}"
  [ "$status" -eq 0 ]
  [ "$output" = "Would edit: ${test_dir}" ]
}
