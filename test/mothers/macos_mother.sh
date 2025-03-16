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
