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
