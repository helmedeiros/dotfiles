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

# Test GitHub API interaction
@test "fetches number of versions correctly" {
  # Setup test configuration
  setup_github_config "${TEST_DIR}"

  # Run the script and capture output
  run "${GH_PACKAGES_SCRIPT}"

  # Assert the script found the correct number of versions
  [ "$status" -eq 0 ]
  [[ "$output" == *"Found 25 versions"* ]]
}

@test "handles API errors gracefully" {
  # Setup test configuration
  setup_github_config "${TEST_DIR}"

  # Modify mock to simulate API error
  cat > "${TEST_DIR}/mocks/curl" << 'EOF'
#!/usr/bin/env bash
echo '{"message": "API Error"}'
exit 1
EOF

  # Run the script and capture output
  run "${GH_PACKAGES_SCRIPT}"

  # Assert the script handled the error
  [ "$status" -eq 1 ]
  [[ "$output" == *"API Error"* ]]
}

@test "skips cleanup when versions count is within limit" {
  # Setup test configuration with high version limit
  setup_github_config "${TEST_DIR}"
  echo "export VERSIONS_TO_KEEP=30" >> "${TEST_DIR}/.dot-secrets/github/packages.sh"

  # Run the script and capture output
  run "${GH_PACKAGES_SCRIPT}"

  # Assert the script skipped cleanup
  [ "$status" -eq 0 ]
  [[ "$output" == *"No cleanup needed"* ]]
}

@test "deletes old versions correctly" {
  # Setup test configuration with low version limit
  setup_github_config "${TEST_DIR}"
  echo "export VERSIONS_TO_KEEP=1" >> "${TEST_DIR}/.dot-secrets/github/packages.sh"

  # Run the script and capture output
  run "${GH_PACKAGES_SCRIPT}"

  # Assert the script deleted old versions
  [ "$status" -eq 0 ]
  [[ "$output" == *"Deleting version"* ]]
  [[ "$output" == *"Cleanup complete"* ]]
}

@test "handles empty version list" {
  # Setup test configuration
  setup_github_config "${TEST_DIR}"

  # Modify mock to return empty version list
  cat > "${TEST_DIR}/mocks/curl" << 'EOF'
#!/usr/bin/env bash
if [[ "$*" == *"/versions?"* ]]; then
    echo '[]'
else
    echo '{"version_count": 0}'
fi
EOF

  # Run the script and capture output
  run "${GH_PACKAGES_SCRIPT}"

  # Assert the script handled empty version list
  [ "$status" -eq 0 ]
  [[ "$output" == *"Found 0 versions"* ]]
  [[ "$output" == *"No cleanup needed"* ]]
}

# Test package version management
@test "respects custom version retention limit" {
  # Setup test configuration with custom version limit
  setup_github_config "${TEST_DIR}"
  echo "export VERSIONS_TO_KEEP=5" >> "${TEST_DIR}/.dot-secrets/github/packages.sh"

  # Run the script and capture output
  run "${GH_PACKAGES_SCRIPT}"

  # Assert the script respects the custom limit
  [ "$status" -eq 0 ]
  [[ "$output" == *"Will keep the 5 most recent versions"* ]]
}

@test "handles version deletion in correct order" {
  # Setup test configuration with low version limit
  setup_github_config "${TEST_DIR}"
  echo "export VERSIONS_TO_KEEP=1" >> "${TEST_DIR}/.dot-secrets/github/packages.sh"

  # Modify mock to return ordered versions
  cat > "${TEST_DIR}/mocks/curl" << 'EOF'
#!/usr/bin/env bash
if [[ "$*" == *"/versions?"* ]]; then
    echo '[{"id": "1", "name": "1.0.0"}, {"id": "2", "name": "1.0.1"}, {"id": "3", "name": "1.0.2"}]'
else
    echo '{"version_count": 3}'
fi
EOF

  # Run the script and capture output
  run "${GH_PACKAGES_SCRIPT}"

  # Assert the script deletes versions in correct order
  [ "$status" -eq 0 ]
  [[ "$output" == *"Deleting version 1.0.0"* ]]
  [[ "$output" == *"Deleting version 1.0.1"* ]]
  [[ "$output" != *"Deleting version 1.0.2"* ]]
}
