#!/usr/bin/env bats

# Path to the script being tested
TODO_SCRIPT="${BATS_TEST_DIRNAME}/../../bin/todo"

setup() {
  TEST_DIR="$(mktemp -d)"
  ORIGINAL_DIR="$(pwd)"

  # Override HOME to avoid touching the real Desktop
  export REAL_HOME="${HOME}"
  export HOME="${TEST_DIR}"
  mkdir -p "${HOME}/Desktop"
}

teardown() {
  export HOME="${REAL_HOME}"
  cd "${ORIGINAL_DIR}"
  rm -rf "${TEST_DIR}"
}

@test "todo script exists and is executable" {
  [ -f "${TODO_SCRIPT}" ]
  [ -x "${TODO_SCRIPT}" ]
}

@test "todo creates a file on the Desktop" {
  run bash "${TODO_SCRIPT}" "my task"
  [ "$status" -eq 0 ]
  [ -f "${TEST_DIR}/Desktop/my task" ]
}

@test "todo creates a file with spaces in the name" {
  run bash "${TODO_SCRIPT}" "buy groceries for dinner"
  [ "$status" -eq 0 ]
  [ -f "${TEST_DIR}/Desktop/buy groceries for dinner" ]
}

@test "todo creates an empty file" {
  run bash "${TODO_SCRIPT}" "empty task"
  [ "$status" -eq 0 ]
  [ ! -s "${TEST_DIR}/Desktop/empty task" ]
}
