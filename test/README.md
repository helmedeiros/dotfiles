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

## Writing Tests

Tests are written using the Bats framework. Each test file should:

1. Load the library being tested
2. Define setup and teardown functions if needed
3. Define test cases using the `@test` annotation

Example:

```bash
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