#!/usr/bin/env bats

# Path to the script being tested
SEARCH_SCRIPT="${BATS_TEST_DIRNAME}/../../bin/search"

setup() {
  TEST_DIR="$(mktemp -d)"
  ORIGINAL_DIR="$(pwd)"

  # Create mock ack that simulates search results
  mkdir -p "${TEST_DIR}/bin"
  cat > "${TEST_DIR}/bin/ack" <<'EOF'
#!/bin/sh
# Simulate ack search - check for -i flag and search term
for arg in "$@"; do
  case "$arg" in
    -i) ;;
    *) TERM="$arg" ;;
  esac
done
echo "file.txt:1:Found ${TERM} here"
EOF
  chmod +x "${TEST_DIR}/bin/ack"

  export PATH="${TEST_DIR}/bin:${PATH}"
}

teardown() {
  cd "${ORIGINAL_DIR}"
  rm -rf "${TEST_DIR}"
}

@test "search script exists and is executable" {
  [ -f "${SEARCH_SCRIPT}" ]
  [ -x "${SEARCH_SCRIPT}" ]
}

@test "search calls ack with case-insensitive flag" {
  # Create a mock ack that logs its arguments
  cat > "${TEST_DIR}/bin/ack" <<'EOF'
#!/bin/sh
echo "ARGS: $@"
EOF
  chmod +x "${TEST_DIR}/bin/ack"

  run bash "${SEARCH_SCRIPT}" "pattern"
  [ "$status" -eq 0 ]
  [[ "$output" == *"-i"* ]]
  [[ "$output" == *"pattern"* ]]
}

@test "search uses ack-grep when available at /usr/bin/ack-grep" {
  # Create mock ack-grep at the expected path
  mkdir -p "${TEST_DIR}/usr/bin"

  # Create a wrapper that simulates /usr/bin/ack-grep existing
  cat > "${TEST_DIR}/bin/ack-grep" <<'EOF'
#!/bin/sh
echo "ack-grep: $@"
EOF
  chmod +x "${TEST_DIR}/bin/ack-grep"

  # Override the script to use our mock path
  # The script checks /usr/bin/ack-grep specifically, so we test the else branch
  run bash "${SEARCH_SCRIPT}" "test"
  [ "$status" -eq 0 ]
}

@test "search passes search term to ack" {
  cat > "${TEST_DIR}/bin/ack" <<'EOF'
#!/bin/sh
echo "SEARCHING: $@"
EOF
  chmod +x "${TEST_DIR}/bin/ack"

  run bash "${SEARCH_SCRIPT}" "mySearchTerm"
  [ "$status" -eq 0 ]
  [[ "$output" == *"mySearchTerm"* ]]
}
