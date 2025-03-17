#!/usr/bin/env bats

# Require BATS version 1.5.0 or higher for run flags
bats_require_minimum_version 1.5.0

# Path to the script being tested
E_SCRIPT="${BATS_TEST_DIRNAME}/../../bin/e"

# Load the Object Mother
load "../mothers/test_mother.sh"
load "../mothers/editor_mother.sh"
load "../mothers/e_mother.sh"

# Setup function that runs before each test
setup() {
  # Create a temporary directory for test files
  TEST_DIR="$(mktemp -d)"

  # Set up environment variables
  export HOME="${TEST_DIR}"

  # Create e script mocks
  E_SCRIPT="$(create_dot_e_mocks "${TEST_DIR}" "${E_SCRIPT}")"
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
  setup_editor_env "${TEST_DIR}" "valid"
  run "${E_SCRIPT}"
  [ "$status" -eq 0 ]
  [ "$output" = "Would edit: ." ]
}

# Test opening specified directory
@test "e opens specified directory when argument is provided" {
  setup_editor_env "${TEST_DIR}" "valid"
  local test_dir="$(create_dot_e_test_dir "${TEST_DIR}" "test_dir")"

  run "${E_SCRIPT}" "${test_dir}"
  [ "$status" -eq 0 ]
  [ "$output" = "Would edit: ${test_dir}" ]
}

# Test editor environment variable scenarios
@test "e uses editor from EDITOR environment variable" {
  setup_editor_env "${TEST_DIR}" "valid"
  run "${E_SCRIPT}"
  [ "$status" -eq 0 ]
  [ "$output" = "Would edit: ." ]
}

@test "e uses editor from full path in EDITOR environment variable" {
  setup_editor_env "${TEST_DIR}" "full_path"
  run "${E_SCRIPT}"
  [ "$status" -eq 0 ]
  [ "$output" = "Would edit: ." ]
}

@test "e fails when EDITOR is not set" {
  setup_editor_env "${TEST_DIR}" "unset"
  run "${E_SCRIPT}"
  [ "$status" -eq 1 ]
  [[ "$output" == *"EDITOR is not set"* ]]
}

@test "e fails when EDITOR is empty" {
  setup_editor_env "${TEST_DIR}" "empty"
  run "${E_SCRIPT}"
  [ "$status" -eq 1 ]
  [[ "$output" == *"EDITOR is not set"* ]]
}

@test "e fails when EDITOR points to nonexistent command" {
  setup_editor_env "${TEST_DIR}" "nonexistent"
  run -127 "${E_SCRIPT}"
  [ "$status" -eq 127 ]
}

# Test path handling scenarios
@test "e handles paths with spaces" {
  setup_editor_env "${TEST_DIR}" "valid"
  local test_dirs=($(create_special_test_dirs "${TEST_DIR}"))
  local space_dir="${test_dirs[0]}"

  run "${E_SCRIPT}" "${space_dir}"
  [ "$status" -eq 0 ]
  [ "$output" = "Would edit: ${space_dir}" ]
}

@test "e handles paths with special characters" {
  setup_editor_env "${TEST_DIR}" "valid"
  local test_dirs=($(create_special_test_dirs "${TEST_DIR}"))
  local special_dir="${test_dirs[1]}"

  run "${E_SCRIPT}" "${special_dir}"
  [ "$status" -eq 0 ]
  [ "$output" = "Would edit: ${special_dir}" ]
}

@test "e handles absolute paths" {
  setup_editor_env "${TEST_DIR}" "valid"
  local test_dirs=($(create_special_test_dirs "${TEST_DIR}"))
  local abs_dir="${test_dirs[2]}"

  run "${E_SCRIPT}" "${abs_dir}"
  [ "$status" -eq 0 ]
  [ "$output" = "Would edit: ${abs_dir}" ]
}

@test "e handles non-existent paths" {
  setup_editor_env "${TEST_DIR}" "valid"
  local test_dirs=($(create_special_test_dirs "${TEST_DIR}"))
  local nonexistent_dir="${test_dirs[3]}"

  run "${E_SCRIPT}" "${nonexistent_dir}"
  [ "$status" -eq 0 ]
  [ "$output" = "Would edit: ${nonexistent_dir}" ]
}

@test "e handles editor command with spaces in path" {
  setup_editor_env "${TEST_DIR}" "with_spaces"
  run "${E_SCRIPT}"
  [ "$status" -eq 0 ]
  [ "$output" = "Would edit: ." ]
}
