#!/usr/bin/env bats

# Path to the script being tested
GIT_UNPUSHED_SCRIPT="${BATS_TEST_DIRNAME}/../../bin/git-unpushed"

# Load the Object Mother
load "../mothers/test_mother.sh"

setup() {
  TEST_DIR="$(mktemp -d)"
  TEST_REPO="${TEST_DIR}/test-repo"
  TEST_REMOTE="${TEST_DIR}/test-remote"
  ORIGINAL_DIR="$(pwd)"

  # Create a mock git that intercepts difftool (which is interactive)
  mkdir -p "${TEST_DIR}/mock-bin"
  cat > "${TEST_DIR}/mock-bin/git" <<'MOCKEOF'
#!/bin/bash
if [[ "$1" == "difftool" ]]; then
  # Replace interactive difftool with non-interactive diff
  shift
  # Remove -y flag if present
  args=()
  for arg in "$@"; do
    [[ "$arg" != "-y" ]] && args+=("$arg")
  done
  exec /usr/bin/git diff "${args[@]}"
else
  exec /usr/bin/git "$@"
fi
MOCKEOF
  chmod +x "${TEST_DIR}/mock-bin/git"
}

teardown() {
  cd "${ORIGINAL_DIR}"
  rm -rf "${TEST_DIR}"
}

@test "git-unpushed script exists and is executable" {
  [ -f "${GIT_UNPUSHED_SCRIPT}" ]
  [ -x "${GIT_UNPUSHED_SCRIPT}" ]
}

@test "git-unpushed shows diff of unpushed changes" {
  a_git_repository_with_remote_tracking "${TEST_REPO}" "${TEST_REMOTE}"
  cd "${TEST_REPO}"

  # Create an unpushed commit
  echo "new feature" > feature.txt
  git add feature.txt
  git commit -m "Add feature"

  # Use mock git to avoid interactive difftool
  export PATH="${TEST_DIR}/mock-bin:${PATH}"

  run bash "${GIT_UNPUSHED_SCRIPT}"
  [ "$status" -eq 0 ]
  [[ "$output" == *"feature.txt"* ]]
}

@test "git-unpushed shows nothing when in sync" {
  a_git_repository_with_remote_tracking "${TEST_REPO}" "${TEST_REMOTE}"
  cd "${TEST_REPO}"

  export PATH="${TEST_DIR}/mock-bin:${PATH}"

  run bash "${GIT_UNPUSHED_SCRIPT}"
  [ "$status" -eq 0 ]
}
