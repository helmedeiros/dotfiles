#!/usr/bin/env bats

# Path to the script being tested
MACOS_DEFAULTS_SCRIPT="${BATS_TEST_DIRNAME}/../../macos/set-defaults.sh"

# Load the Object Mother
load "../mothers/test_mother.sh"
load "../mothers/macos_mother.sh"

# Setup function that runs before each test
setup() {
  # Create a temporary directory for test files
  TEST_DIR="$(mktemp -d)"

  # Create mock commands directory
  mkdir -p "${TEST_DIR}/bin"

  # Create mock defaults command
  create_mock_defaults "${TEST_DIR}/bin/defaults"

  # Create mock osascript command
  create_mock_osascript "${TEST_DIR}/bin/osascript"

  # Create mock killall command
  create_mock_killall "${TEST_DIR}/bin/killall"

  # Create mock chflags command
  create_mock_chflags "${TEST_DIR}/bin/chflags"

  # Add mock commands to PATH
  export PATH="${TEST_DIR}/bin:${PATH}"

  # Create a modified version of the script that uses our mocked environment
  MOCK_SCRIPT="${TEST_DIR}/set-defaults.sh"
  cp "${MACOS_DEFAULTS_SCRIPT}" "${MOCK_SCRIPT}"
  chmod +x "${MOCK_SCRIPT}"

  # Use the modified script for testing
  MACOS_DEFAULTS_SCRIPT="${MOCK_SCRIPT}"

  # Initialize the mock command logs
  MOCK_DEFAULTS_LOG="${TEST_DIR}/defaults.log"
  MOCK_OSASCRIPT_LOG="${TEST_DIR}/osascript.log"
  MOCK_KILLALL_LOG="${TEST_DIR}/killall.log"
  MOCK_CHFLAGS_LOG="${TEST_DIR}/chflags.log"

  touch "$MOCK_DEFAULTS_LOG" "$MOCK_OSASCRIPT_LOG" "$MOCK_KILLALL_LOG" "$MOCK_CHFLAGS_LOG"
}

# Teardown function that runs after each test
teardown() {
  # Clean up the temporary directory
  rm -rf "${TEST_DIR}"
}

# Test that the script exists and is executable
@test "macOS defaults script exists and is executable" {
  [ -f "$MACOS_DEFAULTS_SCRIPT" ]
  [ -x "$MACOS_DEFAULTS_SCRIPT" ]
}

# Test trackpad settings
@test "configures trackpad tap to click" {
  run "$MACOS_DEFAULTS_SCRIPT"

  # Check if defaults were called with correct arguments
  grep "write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true" "$MOCK_DEFAULTS_LOG"
  grep "write NSGlobalDomain com.apple.mouse.tapBehavior -int 1" "$MOCK_DEFAULTS_LOG"
}

# Test keyboard settings
@test "configures keyboard settings" {
  run "$MACOS_DEFAULTS_SCRIPT"

  # Check Fn key setting
  grep "write -g com.apple.keyboard.fnState -bool true" "$MOCK_DEFAULTS_LOG"

  # Check key repeat settings
  grep "write NSGlobalDomain KeyRepeat -int 2" "$MOCK_DEFAULTS_LOG"
  grep "write NSGlobalDomain InitialKeyRepeat -int 15" "$MOCK_DEFAULTS_LOG"
  grep "write NSGlobalDomain ApplePressAndHoldEnabled -bool false" "$MOCK_DEFAULTS_LOG"
}

# Test Finder settings
@test "configures Finder settings" {
  run "$MACOS_DEFAULTS_SCRIPT"

  # Check list view setting
  grep "write com.apple.Finder FXPreferredViewStyle Nlsv" "$MOCK_DEFAULTS_LOG"

  # Check desktop icons settings
  grep "write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true" "$MOCK_DEFAULTS_LOG"
  grep "write com.apple.finder ShowRemovableMediaOnDesktop -bool true" "$MOCK_DEFAULTS_LOG"
}

# Test Dock settings
@test "configures Dock settings" {
  run "$MACOS_DEFAULTS_SCRIPT"

  # Check auto-hide settings
  grep "write com.apple.dock autohide -bool true" "$MOCK_DEFAULTS_LOG"
  grep "write com.apple.dock autohide-delay -float 0" "$MOCK_DEFAULTS_LOG"

  # Check magnification settings
  grep "write com.apple.dock magnification -bool true" "$MOCK_DEFAULTS_LOG"
  grep "write com.apple.dock tilesize -float 30" "$MOCK_DEFAULTS_LOG"
  grep "write com.apple.dock largesize -float 100" "$MOCK_DEFAULTS_LOG"

  # Check if Dock was restarted
  grep "Dock" "$MOCK_KILLALL_LOG"
}

# Test Safari settings
@test "configures Safari settings" {
  run "$MACOS_DEFAULTS_SCRIPT"

  # Check developer settings
  grep "write com.apple.Safari IncludeDevelopMenu -bool true" "$MOCK_DEFAULTS_LOG"
  grep "write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true" "$MOCK_DEFAULTS_LOG"
  grep "write NSGlobalDomain WebKitDeveloperExtras -bool true" "$MOCK_DEFAULTS_LOG"
}

# Test App Store settings
@test "configures App Store settings" {
  run "$MACOS_DEFAULTS_SCRIPT"

  # Check update settings
  grep "write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true" "$MOCK_DEFAULTS_LOG"
  grep "write com.apple.SoftwareUpdate ScheduleFrequency -int 1" "$MOCK_DEFAULTS_LOG"
  grep "write com.apple.SoftwareUpdate AutomaticDownload -int 1" "$MOCK_DEFAULTS_LOG"

  # Check app auto-update settings
  grep "write com.apple.commerce AutoUpdate -bool true" "$MOCK_DEFAULTS_LOG"
  grep "write com.apple.commerce AutoUpdateRestartRequired -bool true" "$MOCK_DEFAULTS_LOG"
}
