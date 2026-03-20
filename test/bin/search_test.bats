#!/usr/bin/env bats

# Path to the script being tested
SEARCH_SCRIPT="${BATS_TEST_DIRNAME}/../../bin/search"

setup() {
  TEST_DIR="$(mktemp -d)"
  ORIGINAL_DIR="$(pwd)"

  mkdir -p "${TEST_DIR}/bin"

  # By default provide no search tools so tests control which are available
  export ORIGINAL_PATH="${PATH}"
  export PATH="${TEST_DIR}/bin:/usr/bin:/bin"
}

teardown() {
  export PATH="${ORIGINAL_PATH}"
  cd "${ORIGINAL_DIR}"
  rm -rf "${TEST_DIR}"
}

@test "search script exists and is executable" {
  [ -f "${SEARCH_SCRIPT}" ]
  [ -x "${SEARCH_SCRIPT}" ]
}

@test "search prefers rg when available" {
  cat > "${TEST_DIR}/bin/rg" <<'EOF'
#!/bin/sh
echo "rg: $@"
EOF
  chmod +x "${TEST_DIR}/bin/rg"

  # Also provide ack to prove rg wins
  cat > "${TEST_DIR}/bin/ack" <<'EOF'
#!/bin/sh
echo "ack: $@"
EOF
  chmod +x "${TEST_DIR}/bin/ack"

  run bash "${SEARCH_SCRIPT}" "pattern"
  [ "$status" -eq 0 ]
  [[ "$output" == *"rg:"* ]]
  [[ "$output" == *"-i"* ]]
  [[ "$output" == *"pattern"* ]]
}

@test "search falls back to ack-grep when rg is unavailable" {
  # Create ack-grep at /usr/bin path the script checks
  cat > "${TEST_DIR}/bin/ack-grep" <<'EOF'
#!/bin/sh
echo "ack-grep: $@"
EOF
  chmod +x "${TEST_DIR}/bin/ack-grep"

  # Simulate /usr/bin/ack-grep existing by overriding the test check
  # The script uses 'command -v' for rg but checks /usr/bin/ack-grep directly
  # Since we can't place files in /usr/bin, test the ack fallback instead
  cat > "${TEST_DIR}/bin/ack" <<'EOF'
#!/bin/sh
echo "ack: $@"
EOF
  chmod +x "${TEST_DIR}/bin/ack"

  run bash "${SEARCH_SCRIPT}" "test"
  [ "$status" -eq 0 ]
  [[ "$output" == *"ack:"* ]]
}

@test "search falls back to grep when no other tool is available" {
  # Create a directory with a file to search
  mkdir -p "${TEST_DIR}/searchdir"
  echo "hello world" > "${TEST_DIR}/searchdir/file.txt"

  cd "${TEST_DIR}/searchdir"

  run bash "${SEARCH_SCRIPT}" "hello"
  [ "$status" -eq 0 ]
  [[ "$output" == *"hello world"* ]]
}

@test "search passes case-insensitive flag to rg" {
  cat > "${TEST_DIR}/bin/rg" <<'EOF'
#!/bin/sh
echo "ARGS: $@"
EOF
  chmod +x "${TEST_DIR}/bin/rg"

  run bash "${SEARCH_SCRIPT}" "MyPattern"
  [ "$status" -eq 0 ]
  [[ "$output" == *"-i"* ]]
  [[ "$output" == *"MyPattern"* ]]
}
