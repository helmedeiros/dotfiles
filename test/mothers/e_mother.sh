#!/usr/bin/env bash
#
# e_mother.sh
#
# Object Mother for e script test fixtures

# Creates a mock e script for testing
create_dot_e_mocks() {
  local test_dir="$1"
  local script_path="$2"

  # Create a modified version of the script that uses our mocked environment
  MOCK_SCRIPT="${test_dir}/e"
  cp "${script_path}" "${MOCK_SCRIPT}"
  chmod +x "${MOCK_SCRIPT}"

  # Use the modified script for testing
  echo "${MOCK_SCRIPT}"
}

# Creates a test directory for e script tests
create_dot_e_test_dir() {
  local test_dir="$1"
  local dir_name="$2"

  local test_path="${test_dir}/${dir_name}"
  mkdir -p "${test_path}"
  echo "${test_path}"
}
