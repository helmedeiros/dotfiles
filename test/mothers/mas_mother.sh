#!/usr/bin/env bash
#
# mas_mother.sh
#
# Object Mother for Mac App Store (mas) related test fixtures

# Creates a mock mas command that logs its arguments
create_dot_mas_mocks() {
  local test_dir="$1"

  # Create mock commands directory if it doesn't exist
  mkdir -p "${test_dir}/bin"

  # Create mock mas command
  cat > "${test_dir}/bin/mas" << 'EOL'
#!/bin/sh
echo "$0 $*" >> "$(dirname "$0")/../mas.log"
exit 0
EOL
  chmod +x "${test_dir}/bin/mas"
}
