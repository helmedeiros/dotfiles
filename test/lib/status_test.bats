#!/usr/bin/env bats

# Load the library to be tested
load "../../lib/status.sh"

# Load the Object Mother
load "../mothers/test_mother.sh"

# Setup function that runs before each test
setup() {
  # Create a temporary directory for test files
  TEST_DIR="$(mktemp -d)"

  # Override the status file and log file paths to use our test directory
  DOTFILES_STATUS_FILE="${TEST_DIR}/test_status.json"
  DOTFILES_STATUS_LOG="${TEST_DIR}/test_log.txt"
  DOTFILES_LAST_CHECK_FILE="${TEST_DIR}/test_last_check.txt"

  # Create an empty log file
  touch "${DOTFILES_STATUS_LOG}"
}

# Teardown function that runs after each test
teardown() {
  # Clean up the temporary directory
  rm -rf "${TEST_DIR}"
}

# Test status_log function
@test "status_log should append messages to the log file" {
  status_log "Test message"

  # Check if the log file contains our message
  run grep "Test message" "${DOTFILES_STATUS_LOG}"
  [ "$status" -eq 0 ]
}

# Test status_update function
@test "status_update should create a status file with the correct format" {
  status_update "test" "Test status message"

  # Check if the status file exists
  [ -f "${DOTFILES_STATUS_FILE}" ]

  # Check if the status file contains the correct type
  run grep -q '"type":"test"' "${DOTFILES_STATUS_FILE}"
  [ "$status" -eq 0 ]

  # Check if the status file contains the correct message
  run grep -q '"message":"Test status message"' "${DOTFILES_STATUS_FILE}"
  [ "$status" -eq 0 ]
}

# Test status_clear function
@test "status_clear should remove the status file" {
  # Create a status file using the Object Mother
  a_status_file_with "${TEST_DIR}" "test" "Test status message"

  # Verify it exists
  [ -f "${DOTFILES_STATUS_FILE}" ]

  # Clear the status
  status_clear

  # Verify the file is gone
  [ ! -f "${DOTFILES_STATUS_FILE}" ]
}

# Test status_exists function
@test "status_exists should return true if status type exists" {
  # Create a status file using the Object Mother
  a_status_file_with "${TEST_DIR}" "test" "Test status message"

  # Check if status_exists returns true for "test"
  run status_exists "test"
  [ "$status" -eq 0 ]

  # Check if status_exists returns false for "nonexistent"
  run status_exists "nonexistent"
  [ "$status" -eq 1 ]
}

# Test status_get_type function
@test "status_get_type should return the correct status type" {
  # Create a status file using the Object Mother
  a_status_file_with "${TEST_DIR}" "test" "Test status message"

  # Check if status_get_type returns "test"
  run status_get_type
  [ "$output" = "test" ]
}

# Test status_get_message function
@test "status_get_message should return the correct status message" {
  # Create a status file using the Object Mother
  a_status_file_with "${TEST_DIR}" "test" "Test status message"

  # Check if status_get_message returns "Test status message"
  run status_get_message
  [ "$output" = "Test status message" ]
}

# Test status_get_prompt function
@test "status_get_prompt should return the correct prompt format" {
  # Test for dotfiles update using the Object Mother
  a_scenario_with_dotfiles_update "${TEST_DIR}"
  run status_get_prompt
  [[ "$output" == *"[DOTFILES UPDATE]"* ]]

  # Test for brew update using the Object Mother
  a_scenario_with_brew_update "${TEST_DIR}"
  run status_get_prompt
  [[ "$output" == *"[BREW UPDATE]"* ]]

  # Test for npm update using the Object Mother
  a_scenario_with_npm_update "${TEST_DIR}"
  run status_get_prompt
  [[ "$output" == *"[NPM UPDATE]"* ]]

  # Test for unknown update using the Object Mother
  a_scenario_with_unknown_update "${TEST_DIR}"
  run status_get_prompt
  [[ "$output" == *"[SYSTEM UPDATE]"* ]]

  # Test for no updates
  status_clear
  run status_get_prompt
  [[ "$output" == *"[No updates]"* ]]
}

# Test status_last_check function
@test "status_last_check should create a last check file if it doesn't exist" {
  # Run status_last_check
  run status_last_check

  # Check if the last check file was created
  [ -f "${DOTFILES_LAST_CHECK_FILE}" ]

  # Check if the function returned 1 (indicating a check should be performed)
  [ "$status" -eq 1 ]
}

@test "status_last_check should return 0 if already checked today" {
  # Create a last check file with today's date using the Object Mother
  a_scenario_with_last_check_today "${TEST_DIR}"

  # Run status_last_check
  run status_last_check

  # Check if the function returned 0 (indicating no check needed)
  [ "$status" -eq 0 ]
}

@test "status_last_check should return 1 if not checked today" {
  # Create a last check file with yesterday's date using the Object Mother
  a_scenario_with_last_check_yesterday "${TEST_DIR}"

  # Run status_last_check
  run status_last_check

  # Check if the function returned 1 (indicating a check should be performed)
  [ "$status" -eq 1 ]

  # Check if the last check file was updated to today's date
  [ "$(cat ${DOTFILES_LAST_CHECK_FILE})" = "$(date +%Y%m%d)" ]
}

# Test status_force_check function
@test "status_force_check should remove the last check file" {
  # Create a last check file with today's date using the Object Mother
  a_scenario_with_last_check_today "${TEST_DIR}"

  # Verify it exists
  [ -f "${DOTFILES_LAST_CHECK_FILE}" ]

  # Force a check
  status_force_check

  # Verify the file is gone
  [ ! -f "${DOTFILES_LAST_CHECK_FILE}" ]
}
