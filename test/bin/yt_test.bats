#!/usr/bin/env bats

# Path to the script being tested
YT_SCRIPT="${BATS_TEST_DIRNAME}/../../bin/yt"

setup() {
  TEST_DIR="$(mktemp -d)"
  ORIGINAL_DIR="$(pwd)"

  # Override HOME so ~/Desktop points to our temp dir
  export REAL_HOME="${HOME}"
  export HOME="${TEST_DIR}"
  mkdir -p "${HOME}/Desktop"

  # Create mock youtube-dl
  mkdir -p "${TEST_DIR}/bin"
  cat > "${TEST_DIR}/bin/youtube-dl" <<'EOF'
#!/bin/sh
echo "Downloading: $1"
touch "video_$(echo "$1" | sed 's/[^a-zA-Z0-9]/_/g').mp4"
EOF
  chmod +x "${TEST_DIR}/bin/youtube-dl"

  export PATH="${TEST_DIR}/bin:${PATH}"
}

teardown() {
  export HOME="${REAL_HOME}"
  cd "${ORIGINAL_DIR}"
  rm -rf "${TEST_DIR}"
}

@test "yt script exists and is executable" {
  [ -f "${YT_SCRIPT}" ]
  [ -x "${YT_SCRIPT}" ]
}

@test "yt calls youtube-dl with the URL argument" {
  cat > "${TEST_DIR}/bin/youtube-dl" <<'EOF'
#!/bin/sh
echo "URL: $1"
EOF
  chmod +x "${TEST_DIR}/bin/youtube-dl"

  run bash "${YT_SCRIPT}" "https://youtube.com/watch?v=test123"
  [ "$status" -eq 0 ]
  [[ "$output" == *"https://youtube.com/watch?v=test123"* ]]
}

@test "yt changes to Desktop directory before downloading" {
  cat > "${TEST_DIR}/bin/youtube-dl" <<'EOF'
#!/bin/sh
echo "CWD: $(pwd)"
EOF
  chmod +x "${TEST_DIR}/bin/youtube-dl"

  run bash "${YT_SCRIPT}" "https://example.com/video"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Desktop"* ]]
}
