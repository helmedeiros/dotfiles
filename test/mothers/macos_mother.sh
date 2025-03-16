#!/usr/bin/env bash

# Creates a mock defaults command that logs its arguments
create_mock_defaults() {
  local mock_path="$1"
  cat > "$mock_path" << 'EOL'
#!/bin/sh
echo "$0 $*" >> "$(dirname "$0")/../defaults.log"
exit 0
EOL
  chmod +x "$mock_path"
}

# Creates a mock osascript command that logs its arguments
create_mock_osascript() {
  local mock_path="$1"
  cat > "$mock_path" << 'EOL'
#!/bin/sh
echo "$0 $*" >> "$(dirname "$0")/../osascript.log"
exit 0
EOL
  chmod +x "$mock_path"
}

# Creates a mock killall command that logs its arguments
create_mock_killall() {
  local mock_path="$1"
  cat > "$mock_path" << 'EOL'
#!/bin/sh
echo "$0 $*" >> "$(dirname "$0")/../killall.log"
exit 0
EOL
  chmod +x "$mock_path"
}

# Creates a mock chflags command that logs its arguments
create_mock_chflags() {
  local mock_path="$1"
  cat > "$mock_path" << 'EOL'
#!/bin/sh
echo "$0 $*" >> "$(dirname "$0")/../chflags.log"
exit 0
EOL
  chmod +x "$mock_path"
}

# Create macOS mocks for dot script testing
create_dot_macos_mocks() {
  local test_dir="$1"

  # Create dotfiles directory structure if it doesn't exist
  mkdir -p "${test_dir}/.dotfiles/macos"

  # Create mock set-defaults.sh script
  cat > "${test_dir}/.dotfiles/macos/set-defaults.sh" << 'EOL'
#!/bin/sh
echo "$0" >> "$(dirname "$0")/../../macos.log"
exit 0
EOL
  chmod +x "${test_dir}/.dotfiles/macos/set-defaults.sh"

  # Initialize the macOS log
  MOCK_MACOS_LOG="${test_dir}/macos.log"
  touch "$MOCK_MACOS_LOG"
}
