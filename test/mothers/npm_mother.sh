#!/bin/bash
#
# npm_mother.sh
#
# Object Mother for npm-related test fixtures

# Function to create an npm mock with customizable behavior
npm_mother_create_mock() {
  local test_dir="$1"
  local has_outdated="$2"
  local current_versions="$3"
  local latest_versions="$4"

  mkdir -p "${test_dir}/bin"

  # Create a mock npm command
  cat > "${test_dir}/bin/npm" <<EOF
#!/bin/bash
if [[ "\$1" == "list" ]]; then
  echo '${current_versions}'
elif [[ "\$1" == "view" && "\$3" == "version" ]]; then
  if [[ "\$2" == "package1" ]]; then
    echo "${latest_versions[0]}"
  elif [[ "\$2" == "package2" ]]; then
    echo "${latest_versions[1]}"
  else
    echo "1.0.0"  # Default version
  fi
else
  echo "Mock npm: Unknown command: \$@" >&2
  exit 0
fi
EOF
  chmod +x "${test_dir}/bin/npm"

  # Create a mock jq command
  cat > "${test_dir}/bin/jq" <<EOF
#!/bin/bash
if [[ "\$1" == "-e" && "\$2" == "." ]]; then
  # Validate JSON
  exit 0
elif [[ "\$1" == "-r" && "\$2" == ".dependencies | to_entries[] | \"\(.key)@\(.value.version)\"" ]]; then
  # Extract package names and versions
  echo "package1@${current_versions[0]}"
  echo "package2@${current_versions[1]}"
else
  echo "Mock jq: Unknown command: \$@" >&2
  exit 0
fi
EOF
  chmod +x "${test_dir}/bin/jq"

  # Create a mock nvm command
  mkdir -p "${test_dir}/node"
  cat > "${test_dir}/node/path.zsh" <<EOF
#!/bin/bash
# Mock NVM environment
EOF
  chmod +x "${test_dir}/node/path.zsh"

  # Mock the command command to prevent real command checks
  cat > "${test_dir}/bin/command" <<EOF
#!/bin/bash
if [[ "\$2" == "brew" ]]; then
  exit 0  # Pretend brew is installed
elif [[ "\$2" == "npm" ]]; then
  exit 0  # Pretend npm is installed
elif [[ "\$2" == "git" ]]; then
  exit 0  # Pretend git is installed
elif [[ "\$2" == "nvm" ]]; then
  exit 0  # Pretend nvm is installed
else
  exit 1  # Command not found
fi
EOF
  chmod +x "${test_dir}/bin/command"
}

# Create an npm mock for the "up to date" scenario
# A system with no outdated npm packages
an_npm_with_no_outdated_packages() {
  local test_dir="$1"
  local current_versions=("1.0.0" "2.0.0")
  local latest_versions=("1.0.0" "2.0.0")

  local current_json='{"dependencies":{"package1":{"version":"1.0.0"},"package2":{"version":"2.0.0"}}}'

  npm_mother_create_mock "$test_dir" false "$current_json" "${latest_versions[@]}"
}

# Create an npm mock for the "outdated packages" scenario
# A system with outdated npm packages
an_npm_with_outdated_packages() {
  local test_dir="$1"
  local current_versions=("1.0.0" "2.0.0")
  local latest_versions=("1.1.0" "2.1.0")

  local current_json='{"dependencies":{"package1":{"version":"1.0.0"},"package2":{"version":"2.0.0"}}}'

  npm_mother_create_mock "$test_dir" true "$current_json" "${latest_versions[@]}"
}

# Create npm mocks for dot script testing
create_dot_npm_mocks() {
  local test_dir="$1"

  # Create mock nvm command
  cat > "${test_dir}/bin/nvm" << 'EOL'
#!/bin/sh
echo "$0 $*" >> "$(dirname "$0")/../nvm.log"
exit 0
EOL
  chmod +x "${test_dir}/bin/nvm"

  # Create mock npm command
  cat > "${test_dir}/bin/npm" << 'EOL'
#!/bin/sh
echo "$0 $*" >> "$(dirname "$0")/../npm.log"
exit 0
EOL
  chmod +x "${test_dir}/bin/npm"

  # Create mock node command
  cat > "${test_dir}/bin/node" << 'EOL'
#!/bin/sh
if [ "$1" = "-v" ]; then
  echo "v20.17.0"
else
  echo "$0 $*" >> "$(dirname "$0")/../node.log"
fi
exit 0
EOL
  chmod +x "${test_dir}/bin/node"

  # Create mock node/path.zsh script
  mkdir -p "${test_dir}/.dotfiles/node"
  cat > "${test_dir}/.dotfiles/node/path.zsh" << 'EOL'
#!/bin/sh
echo "Mock NVM configuration loaded"
exit 0
EOL
  chmod +x "${test_dir}/.dotfiles/node/path.zsh"

  # Create mock node/install.sh script
  cat > "${test_dir}/.dotfiles/node/install.sh" << 'EOL'
#!/bin/sh
echo "$0" >> "$(dirname "$0")/../../node_install.log"
exit 0
EOL
  chmod +x "${test_dir}/.dotfiles/node/install.sh"
}
