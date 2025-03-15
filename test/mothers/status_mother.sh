#!/bin/bash
#
# status_mother.sh
#
# Object Mother for status-related test fixtures

# Function to create a status file with customizable content
a_status_file_with() {
  local test_dir="$1"
  local status_type="$2"
  local message="$3"
  local timestamp="${4:-$(date '+%Y-%m-%d %H:%M:%S')}"

  local status_file="${test_dir}/test_status.json"

  # Create the status file with the specified content
  echo "{\"type\":\"${status_type}\",\"message\":\"${message}\",\"timestamp\":\"${timestamp}\"}" > "${status_file}"
}

# Function to create a last check file with a specific date
a_last_check_file_with_date() {
  local test_dir="$1"
  local date_string="$2"

  local last_check_file="${test_dir}/test_last_check.txt"

  # Create the last check file with the specified date
  echo "${date_string}" > "${last_check_file}"
}

# Function to create a log file with specific content
a_log_file_with() {
  local test_dir="$1"
  local content="$2"

  local log_file="${test_dir}/test_log.txt"

  # Create the log file with the specified content
  echo "${content}" > "${log_file}"
}

# Common status scenarios

# A status file for dotfiles updates
a_dotfiles_update_status() {
  local test_dir="$1"
  a_status_file_with "${test_dir}" "dotfiles" "Dotfiles updates available"
}

# A status file for brew updates
a_brew_update_status() {
  local test_dir="$1"
  a_status_file_with "${test_dir}" "brew" "Brew updates available"
}

# A status file for npm updates
an_npm_update_status() {
  local test_dir="$1"
  a_status_file_with "${test_dir}" "npm" "npm updates available"
}

# A status file for unknown updates
an_unknown_update_status() {
  local test_dir="$1"
  a_status_file_with "${test_dir}" "unknown" "Unknown updates available"
}

# A last check file with today's date
a_last_check_file_with_today() {
  local test_dir="$1"
  a_last_check_file_with_date "${test_dir}" "$(date +%Y%m%d)"
}

# A last check file with yesterday's date
a_last_check_file_with_yesterday() {
  local test_dir="$1"
  a_last_check_file_with_date "${test_dir}" "$(date -j -v-1d +%Y%m%d)"
}
