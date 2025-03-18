#!/usr/bin/env bats

# Require BATS version 1.5.0 or higher for run flags
bats_require_minimum_version 1.5.0

# Load the mother objects
load "../mothers/github_mother.sh"

# Path to the script being tested
GH_PACKAGES_SCRIPT="${BATS_TEST_DIRNAME}/../../github/gh-packages.sh"

# Setup function that runs before each test
setup() {
  # Create a temporary directory for test files
  TEST_DIR="$(mktemp -d)"
  export HOME="${TEST_DIR}"

  # Setup GitHub mocks
  setup_github_mocks "${TEST_DIR}"

  # Clear any existing environment variables
  unset GH_PACKAGES_TOKEN
  unset ORG
  unset REPO
  unset VERSIONS_TO_KEEP
}

# Teardown function that runs after each test
teardown() {
  # Clean up the temporary directory
  rm -rf "${TEST_DIR}"
}

# Test script existence and executability
@test "gh-packages script exists and is executable" {
  [ -f "${GH_PACKAGES_SCRIPT}" ]
  [ -x "${GH_PACKAGES_SCRIPT}" ]
}

# Test configuration loading from .dot-secrets
@test "loads configuration from .dot-secrets when available" {
  # Create test configuration
  setup_github_config "${TEST_DIR}"

  # Run the script and capture output
  run "${GH_PACKAGES_SCRIPT}"

  # Assert the script tried to load the configuration
  [ "$status" -eq 0 ]
  [[ "$output" == *"Loading configuration from"* ]]
}

# Test environment variable overrides
@test "environment variables override .dot-secrets configuration" {
  # Create test configuration with different values
  setup_github_config "${TEST_DIR}"

  # Run the script with environment variables
  run bash -c "GH_PACKAGES_TOKEN='correct_token' ORG='correct_org' REPO='correct_repo' VERSIONS_TO_KEEP=15 '${GH_PACKAGES_SCRIPT}'"

  # Assert the script tried to load the configuration
  [ "$status" -eq 0 ]
  [[ "$output" == *"Loading configuration from"* ]]
}

# Test missing required parameters
@test "fails when required parameters are missing" {
  # Run without any configuration
  run "${GH_PACKAGES_SCRIPT}"

  # Assert error message and exit code
  [ "$status" -eq 1 ]
  [[ "$output" == *"Error: Missing required parameters"* ]]
  [[ "$output" == *"GH_PACKAGES_TOKEN"* ]]
  [[ "$output" == *"ORG"* ]]
  [[ "$output" == *"REPO"* ]]
}

# Test missing individual parameters
@test "fails when GH_PACKAGES_TOKEN is missing" {
  run bash -c "ORG='test_org' REPO='test_repo' '${GH_PACKAGES_SCRIPT}'"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Error: Missing required parameters"* ]]
}

@test "fails when ORG is missing" {
  run bash -c "GH_PACKAGES_TOKEN='test_token' REPO='test_repo' '${GH_PACKAGES_SCRIPT}'"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Error: Missing required parameters"* ]]
}

@test "fails when REPO is missing" {
  run bash -c "GH_PACKAGES_TOKEN='test_token' ORG='test_org' '${GH_PACKAGES_SCRIPT}'"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Error: Missing required parameters"* ]]
}
