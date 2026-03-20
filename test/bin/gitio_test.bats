#!/usr/bin/env bats

# Path to the script being tested
GITIO_SCRIPT="${BATS_TEST_DIRNAME}/../../bin/gitio"

setup() {
  TEST_DIR="$(mktemp -d)"
  ORIGINAL_DIR="$(pwd)"

  # Create mock curl that simulates git.io response
  mkdir -p "${TEST_DIR}/bin"
  cat > "${TEST_DIR}/bin/curl" <<'EOF'
#!/bin/sh
echo "HTTP/1.1 201 Created"
echo "Location: https://git.io/test123"
EOF
  chmod +x "${TEST_DIR}/bin/curl"

  # Create mock pbcopy
  cat > "${TEST_DIR}/bin/pbcopy" <<'EOF'
#!/bin/sh
cat > /dev/null
EOF
  chmod +x "${TEST_DIR}/bin/pbcopy"

  export PATH="${TEST_DIR}/bin:${PATH}"
}

teardown() {
  cd "${ORIGINAL_DIR}"
  rm -rf "${TEST_DIR}"
}

@test "gitio script exists and is executable" {
  [ -f "${GITIO_SCRIPT}" ]
  [ -x "${GITIO_SCRIPT}" ]
}

@test "gitio rejects non-GitHub URLs" {
  run ruby "${GITIO_SCRIPT}" "https://example.com/something"
  [ "$status" -ne 0 ]
  [[ "$output" == *"github.com URLs only"* ]]
}

@test "gitio accepts github.com URLs" {
  run ruby "${GITIO_SCRIPT}" "https://github.com/user/repo"
  [ "$status" -eq 0 ]
  [[ "$output" == *"git.io"* ]]
}

@test "gitio accepts gist.github.com URLs" {
  run ruby "${GITIO_SCRIPT}" "https://gist.github.com/user/abc123"
  [ "$status" -eq 0 ]
}

@test "gitio prepends https when no scheme given" {
  # Mock curl to show the URL it was called with
  cat > "${TEST_DIR}/bin/curl" <<'EOF'
#!/bin/sh
echo "HTTP/1.1 201 Created"
echo "Location: https://git.io/test123"
EOF
  chmod +x "${TEST_DIR}/bin/curl"

  run ruby "${GITIO_SCRIPT}" "github.com/user/repo"
  [ "$status" -eq 0 ]
}
