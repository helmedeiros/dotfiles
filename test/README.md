# Dotfiles Tests

This directory contains tests for the dotfiles repository.

## Requirements

- [Bats](https://github.com/bats-core/bats-core) - Bash Automated Testing System

You can install Bats using Homebrew:

```bash
brew install bats-core
```

## Running Tests

To run all tests:

```bash
./test/run_tests.sh
```

To run a specific test file:

```bash
bats test/lib/status_test.bats
```

## Test Structure

- `test/lib/` - Tests for library functions
  - `status_test.bats` - Tests for the status.sh library
- `test/bin/` - Tests for bin scripts
  - `check_updates_test.bats` - Tests for the check-updates script
  - `cleanup_brew_test.bats` - Tests for the cleanup-brew script
- `test/mothers/` - Object Mother pattern implementations for test fixtures
  - `git_mother.sh` - Test fixtures for git-related tests
  - `brew_mother.sh` - Test fixtures for brew-related tests
  - `npm_mother.sh` - Test fixtures for npm-related tests
  - `dot_mother.sh` - Test fixtures for dot script-related tests
  - `status_mother.sh` - Test fixtures for status-related tests
  - `test_mother.sh` - Main Object Mother that combines all other mothers

## Writing Tests

Tests are written using the Bats framework. Each test file should:

1. Load the library being tested
2. Define setup and teardown functions if needed
3. Define test cases using the `@test` annotation

Example:

````bash
#!/usr/bin/env bats

# Load the library to be tested
load "../../lib/status.sh"

# Setup function that runs before each test
setup() {
  # Create a temporary directory for test files
  TEST_DIR="$(mktemp -d)"
}

# Teardown function that runs after each test
teardown() {
  # Clean up the temporary directory
  rm -rf "${TEST_DIR}"
}

# Test case
@test "my test case" {
  # Test code here
  [ "expected" = "actual" ]
}

## Object Mother Pattern

The Object Mother pattern is used to create and manage test fixtures in a reusable way. This pattern helps to:

1. **Reduce duplication** - Common test fixtures are defined once and reused across tests
2. **Improve readability** - Tests focus on assertions rather than setup code
3. **Simplify maintenance** - Changes to fixture creation are made in one place

### Using the Object Mother

To use the Object Mother pattern in your tests:

1. Load the appropriate mother file:
   ```bash
   load "../mothers/test_mother.sh"  # Loads the main Object Mother
````

2. Use the provided functions to create test fixtures:

   ```bash
   # Create a git repository with local changes
   a_git_with_local_changes "${TEST_DIR}"

   # Create a brew environment with outdated packages
   a_brew_with_outdated_packages "${TEST_DIR}"

   # Create a complete test environment with predefined scenarios
   test_mother_create_needs_update_scenario "${TEST_DIR}"
   ```

### Available Scenarios

The main `test_mother.sh` provides several predefined scenarios:

- `test_mother_create_up_to_date_scenario` - All components are up to date
- `test_mother_create_needs_update_scenario` - Dotfiles need updates
- `test_mother_create_local_changes_scenario` - Repository has local changes
- `test_mother_create_diverged_scenario` - Repository has diverged from remote

### Creating New Mothers

When adding new functionality that requires testing, consider creating a new Object Mother or extending an existing one to provide reusable test fixtures.
