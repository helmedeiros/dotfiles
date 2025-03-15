#!/bin/bash
#
# dot_mother.sh
#
# Object Mother for dot script-related test fixtures

# Function to create a dot script mock
dot_mother_create_mock() {
  local test_dir="$1"
  local dotfiles_dir="${test_dir}/dotfiles"

  # Create a mock bin/dot script
  mkdir -p "${dotfiles_dir}/bin"
  cat > "${dotfiles_dir}/bin/dot" <<EOF
#!/bin/bash
echo "Running bin/dot..."
echo "bin/dot completed successfully!"
EOF
  chmod +x "${dotfiles_dir}/bin/dot"
}

# Create a standard dot script mock
# A standard dot script that runs successfully
a_standard_dot_script() {
  local test_dir="$1"
  dot_mother_create_mock "$test_dir"
}
