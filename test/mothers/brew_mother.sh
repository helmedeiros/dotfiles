#!/bin/bash
#
# brew_mother.sh
#
# Object Mother for brew-related test fixtures

# Function to create a brew mock with customizable behavior
brew_mother_create_mock() {
  local test_dir="$1"
  local has_outdated="$2"
  local outdated_packages="$3"

  mkdir -p "${test_dir}/bin"

  if [ "$has_outdated" = true ]; then
    cat > "${test_dir}/bin/brew" <<EOF
#!/bin/bash
if [[ "\$1" == "update" ]]; then
  exit 0
elif [[ "\$1" == "outdated" ]]; then
  echo "${outdated_packages}"
else
  echo "Mock brew: Unknown command: \$@" >&2
  exit 0
fi
EOF
  else
    cat > "${test_dir}/bin/brew" <<EOF
#!/bin/bash
if [[ "\$1" == "update" ]]; then
  exit 0
elif [[ "\$1" == "outdated" ]]; then
  # No outdated packages
  echo ""
else
  echo "Mock brew: Unknown command: \$@" >&2
  exit 0
fi
EOF
  fi

  chmod +x "${test_dir}/bin/brew"
}

# Create a brew mock for the "up to date" scenario
# A system with no outdated Homebrew packages
a_brew_with_no_outdated_packages() {
  local test_dir="$1"
  brew_mother_create_mock "$test_dir" false ""
}

# Create a brew mock for the "outdated packages" scenario
# A system with outdated Homebrew packages
a_brew_with_outdated_packages() {
  local test_dir="$1"
  brew_mother_create_mock "$test_dir" true "package1 1.0.0 -> 1.1.0
package2 2.0.0 -> 2.1.0"
}

# Function to create a brew mock for cleanup-brew testing
a_brew_with_disabled_packages() {
  local test_dir="$1"
  local installed_packages="$2"
  local dependencies="$3"

  mkdir -p "${test_dir}/bin"

  cat > "${test_dir}/bin/brew" <<EOF
#!/bin/bash
if [[ "\$1" == "list" ]]; then
  if [[ "${installed_packages}" == *"\$2"* ]]; then
    exit 0
  else
    exit 1
  fi
elif [[ "\$1" == "uses" && "\$2" == "--installed" ]]; then
  if [[ "${dependencies}" == *"\$3"* ]]; then
    echo "some-dependent-package"
    exit 0
  else
    echo ""
    exit 0
  fi
elif [[ "\$1" == "uninstall" ]]; then
  if [[ "\$2" == "--ignore-dependencies" ]]; then
    echo "Uninstalling \$3 (ignoring dependencies)..."
    exit 0
  else
    echo "Uninstalling \$2..."
    exit 0
  fi
else
  echo "Mock brew: Unknown command: \$@" >&2
  exit 1
fi
EOF
  chmod +x "${test_dir}/bin/brew"
}

# A brew environment with no disabled packages installed
a_brew_with_no_disabled_packages() {
  local test_dir="$1"
  a_brew_with_disabled_packages "$test_dir" "" ""
}

# A brew environment with a disabled package that has no dependencies
a_brew_with_disabled_package_no_dependencies() {
  local test_dir="$1"
  local package="${2:-vault}"
  a_brew_with_disabled_packages "$test_dir" "$package" ""
}

# A brew environment with a disabled package that has dependencies
a_brew_with_disabled_package_with_dependencies() {
  local test_dir="$1"
  local package="${2:-openssl@1.1}"
  a_brew_with_disabled_packages "$test_dir" "$package" "$package"
}

# A brew environment with multiple disabled packages
a_brew_with_multiple_disabled_packages() {
  local test_dir="$1"
  a_brew_with_disabled_packages "$test_dir" "vault openssl@1.1 youtube-dl" "openssl@1.1 youtube-dl"
}
