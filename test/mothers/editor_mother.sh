#!/usr/bin/env bash
#
# editor_mother.sh
#
# Object Mother for editor-related test fixtures

# Creates a mock editor that echoes its arguments
create_dot_editor_mocks() {
  local test_dir="$1"

  # Create mock commands directory if it doesn't exist
  mkdir -p "${test_dir}/bin"

  # Create a mock editor that just echoes its arguments
  cat > "${test_dir}/bin/mock-editor" << 'EOL'
#!/bin/sh
echo "Would edit: $@"
exit 0
EOL
  chmod +x "${test_dir}/bin/mock-editor"

  # Set the mock editor as the EDITOR
  export EDITOR="${test_dir}/bin/mock-editor"
}
