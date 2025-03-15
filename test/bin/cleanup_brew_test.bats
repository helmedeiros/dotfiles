#!/usr/bin/env bats

# Path to the script being tested
CLEANUP_BREW_SCRIPT="${BATS_TEST_DIRNAME}/../../bin/cleanup-brew"

# Load the Object Mother
load "../mothers/test_mother.sh"

# Setup function that runs before each test
setup() {
  # Create a temporary directory for test files
  TEST_DIR="$(mktemp -d)"

  # Create a modified version of the cleanup-brew script that uses our mocked environment
  MOCK_SCRIPT="${TEST_DIR}/cleanup-brew"
  cp "${CLEANUP_BREW_SCRIPT}" "${MOCK_SCRIPT}"
  chmod +x "${MOCK_SCRIPT}"

  # Use the modified script for testing
  CLEANUP_BREW_SCRIPT="${MOCK_SCRIPT}"

  # Add the mock bin directory to the PATH (at the beginning to take precedence)
  export PATH="${TEST_DIR}/bin:${PATH}"
}

# Teardown function that runs after each test
teardown() {
  # Clean up the temporary directory
  rm -rf "${TEST_DIR}"
}

# Test that the script exists and is executable
@test "cleanup-brew script exists and is executable" {
  [ -f "$CLEANUP_BREW_SCRIPT" ]
  [ -x "$CLEANUP_BREW_SCRIPT" ]
}

# Test the script when no disabled packages are installed
@test "cleanup-brew reports when no disabled packages are installed" {
  # Create a brew environment with no disabled packages
  a_brew_with_no_disabled_packages "${TEST_DIR}"

  # Run the script
  run "${CLEANUP_BREW_SCRIPT}"

  # Check the output
  [ "$status" -eq 0 ]
  [[ "$output" == *"Package openssl@1.1 is not installed"* ]]
  [[ "$output" == *"Package vault is not installed"* ]]
  [[ "$output" == *"Package xmlto is not installed"* ]]
  [[ "$output" == *"Package pre-commit is not installed"* ]]
  [[ "$output" == *"Package youtube-dl is not installed"* ]]
  [[ "$output" == *"Package spaceman-diff is not installed"* ]]
  [[ "$output" == *"Cleanup completed!"* ]]
}

# Test the script when a disabled package with no dependencies is installed
@test "cleanup-brew uninstalls disabled packages with no dependencies" {
  # Create a brew environment with a disabled package that has no dependencies
  a_brew_with_disabled_package_no_dependencies "${TEST_DIR}" "vault"

  # Run the script
  run "${CLEANUP_BREW_SCRIPT}"

  # Check the output
  [ "$status" -eq 0 ]
  [[ "$output" == *"Found disabled package: vault"* ]]
  [[ "$output" == *"Uninstalling vault..."* ]]
  [[ "$output" == *"Cleanup completed!"* ]]
}

# Test the script when a disabled package with dependencies is installed
@test "cleanup-brew skips disabled packages with dependencies" {
  # Create a brew environment with a disabled package that has dependencies
  a_brew_with_disabled_package_with_dependencies "${TEST_DIR}" "youtube-dl"

  # Run the script
  run "${CLEANUP_BREW_SCRIPT}"

  # Check the output
  [ "$status" -eq 0 ]
  [[ "$output" == *"Found disabled package: youtube-dl"* ]]
  [[ "$output" == *"Warning: youtube-dl is required by: some-dependent-package"* ]]
  [[ "$output" == *"Skipping youtube-dl"* ]]
  [[ "$output" == *"Recommendation: Use yt-dlp instead of youtube-dl"* ]]
  [[ "$output" == *"Cleanup completed!"* ]]
}

# Test the script with force flag when a disabled package with dependencies is installed
@test "cleanup-brew force uninstalls disabled packages with dependencies when --force is used" {
  # Create a brew environment with a disabled package that has dependencies
  a_brew_with_disabled_package_with_dependencies "${TEST_DIR}" "openssl@1.1"

  # Run the script with --force
  run "${CLEANUP_BREW_SCRIPT}" --force

  # Check the output
  [ "$status" -eq 0 ]
  [[ "$output" == *"Force mode enabled"* ]]
  [[ "$output" == *"Found disabled package: openssl@1.1"* ]]
  [[ "$output" == *"Warning: openssl@1.1 is required by: some-dependent-package"* ]]
  [[ "$output" == *"Forcing uninstall of openssl@1.1 (ignoring dependencies)..."* ]]
  [[ "$output" == *"Cleanup completed!"* ]]
}

# Test the script with multiple disabled packages installed
@test "cleanup-brew handles multiple disabled packages correctly" {
  # Create a brew environment with multiple disabled packages
  a_brew_with_multiple_disabled_packages "${TEST_DIR}"

  # Run the script
  run "${CLEANUP_BREW_SCRIPT}"

  # Check the output
  [ "$status" -eq 0 ]
  [[ "$output" == *"Found disabled package: vault"* ]]
  [[ "$output" == *"Uninstalling vault..."* ]]
  [[ "$output" == *"Found disabled package: openssl@1.1"* ]]
  [[ "$output" == *"Warning: openssl@1.1 is required by: some-dependent-package"* ]]
  [[ "$output" == *"Skipping openssl@1.1"* ]]
  [[ "$output" == *"Found disabled package: youtube-dl"* ]]
  [[ "$output" == *"Warning: youtube-dl is required by: some-dependent-package"* ]]
  [[ "$output" == *"Skipping youtube-dl"* ]]
  [[ "$output" == *"Cleanup completed!"* ]]
}
