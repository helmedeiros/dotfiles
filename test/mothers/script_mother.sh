#!/usr/bin/env bash
#
# script_mother.sh
#
# Object Mother for script-related test fixtures

# Creates mock script installation files and logs
create_dot_script_mocks() {
  local test_dir="$1"
  local dotfiles_dir="${test_dir}/.dotfiles"

  # Create mock install.sh script for Homebrew that just logs the call
  mkdir -p "${dotfiles_dir}/homebrew"
  cat > "${dotfiles_dir}/homebrew/install.sh" << 'EOL'
#!/bin/sh
echo "$0" >> "$(dirname "$0")/../../install.log"
exit 0
EOL
  chmod +x "${dotfiles_dir}/homebrew/install.sh"

  # Create mock script/install script
  mkdir -p "${dotfiles_dir}/script"
  cat > "${dotfiles_dir}/script/install" << 'EOL'
#!/bin/sh
echo "$0" >> "$(dirname "$0")/../../script_install.log"
exit 0
EOL
  chmod +x "${dotfiles_dir}/script/install"

  # Create mock Brewfile
  echo "# Brewfile for testing" > "${test_dir}/Brewfile"

  # Initialize the mock command logs
  MOCK_INSTALL_LOG="${test_dir}/install.log"
  MOCK_SCRIPT_INSTALL_LOG="${test_dir}/script_install.log"
  touch "$MOCK_INSTALL_LOG" "$MOCK_SCRIPT_INSTALL_LOG"
}
