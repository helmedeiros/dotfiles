#!/bin/sh
#
# e_mother.sh
#
# Object Mother for e script test fixtures

# Creates a mock e script for testing
create_dot_e_mocks() {
  local test_dir="$1"
  local script_path="$2"

  # Copy the original script to the test directory
  cp "${script_path}" "${test_dir}/e"
  chmod +x "${test_dir}/e"

  echo "${test_dir}/e"
}

# Creates a test directory for e script tests
create_dot_e_test_dir() {
  local test_dir="$1"
  local dir_name="$2"

  local test_path="${test_dir}/${dir_name}"
  mkdir -p "${test_path}"
  echo "${test_path}"
}

# Create test directories with special paths
create_special_test_dirs() {
  local test_dir="$1"
  local result=()

  # Directory with spaces
  local space_dir="${test_dir}/path with spaces"
  mkdir -p "${space_dir}"
  result+=("${space_dir}")

  # Directory with special characters
  local special_dir="${test_dir}/test-dir_with!special@chars"
  mkdir -p "${special_dir}"
  result+=("${special_dir}")

  # Absolute path directory
  local abs_dir="${test_dir}/absolute/path/test"
  mkdir -p "${abs_dir}"
  result+=("${abs_dir}")

  # Non-existent directory (don't create it)
  local nonexistent_dir="${test_dir}/does/not/exist"
  result+=("${nonexistent_dir}")

  echo "${result[@]}"
}

# Sets up environment for testing editor variable
setup_editor_env() {
  local test_dir="$1"
  local editor_type="$2"

  # Create bin directory for mock editors
  mkdir -p "${test_dir}/bin"

  case "${editor_type}" in
    "valid")
      # Create a mock editor that succeeds
      cat > "${test_dir}/bin/mock-editor" << 'EOF'
#!/bin/sh
echo "Would edit: $1"
exit 0
EOF
      chmod +x "${test_dir}/bin/mock-editor"
      export EDITOR="${test_dir}/bin/mock-editor"
      ;;

    "with_args")
      # Create a mock editor that handles arguments
      cat > "${test_dir}/bin/mock-editor" << 'EOF'
#!/bin/sh
echo "Would edit: $1"
exit 0
EOF
      chmod +x "${test_dir}/bin/mock-editor"
      export EDITOR="${test_dir}/bin/mock-editor -R --some-flag"
      ;;

    "with_spaces")
      # Create a mock editor in a path with spaces
      local editor_dir="${test_dir}/Mock Editor.app/Contents/MacOS"
      mkdir -p "${editor_dir}"
      cat > "${editor_dir}/mock-editor" << 'EOF'
#!/bin/sh
echo "Would edit: $1"
exit 0
EOF
      chmod +x "${editor_dir}/mock-editor"
      export EDITOR="${editor_dir}/mock-editor"
      ;;

    "full_path")
      # Create a mock editor with full path
      cat > "${test_dir}/bin/mock-editor" << 'EOF'
#!/bin/sh
echo "Would edit: $1"
exit 0
EOF
      chmod +x "${test_dir}/bin/mock-editor"
      export EDITOR="${test_dir}/bin/mock-editor"
      ;;

    "empty")
      export EDITOR=""
      ;;

    "nonexistent")
      export EDITOR="nonexistent-editor"
      ;;

    "unset")
      unset EDITOR
      ;;

    *)
      echo "Invalid editor type: ${editor_type}" >&2
      return 1
      ;;
  esac
}
