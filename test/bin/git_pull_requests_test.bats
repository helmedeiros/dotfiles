#!/usr/bin/env bats

# Path to the script being tested
GIT_PR_SCRIPT="${BATS_TEST_DIRNAME}/../../bin/git-pull-requests"

# Load the Object Mother
load "../mothers/test_mother.sh"

setup() {
  TEST_DIR="$(mktemp -d)"
  TEST_REPO="${TEST_DIR}/test-repo"
  ORIGINAL_DIR="$(pwd)"

  # Create mock hub command
  mkdir -p "${TEST_DIR}/bin"
  cat > "${TEST_DIR}/bin/hub" <<'EOF'
#!/bin/sh
if [ "$1" = "pr" ] && [ "$2" = "list" ]; then
  echo "#42  Add feature-x  feature-x"
  echo "#99  Fix bug-y      bugfix-y"
fi
EOF
  chmod +x "${TEST_DIR}/bin/hub"

  export PATH="${TEST_DIR}/bin:${PATH}"
}

teardown() {
  cd "${ORIGINAL_DIR}"
  rm -rf "${TEST_DIR}"
}

@test "git-pull-requests script exists and is executable" {
  [ -f "${GIT_PR_SCRIPT}" ]
  [ -x "${GIT_PR_SCRIPT}" ]
}

@test "git-pull-requests lists open PRs" {
  a_real_git_repository_with_branches "${TEST_REPO}"
  cd "${TEST_REPO}"

  # Set up a GitHub-like remote URL
  git remote add origin "https://github.com/user/repo.git"

  run bash "${GIT_PR_SCRIPT}"
  [ "$status" -eq 0 ]
  [[ "$output" == *"PR:"* ]]
  [[ "$output" == *"42"* ]]
  [[ "$output" == *"99"* ]]
}

@test "git-pull-requests handles no open PRs" {
  a_real_git_repository_with_branches "${TEST_REPO}"
  cd "${TEST_REPO}"

  git remote add origin "https://github.com/user/repo.git"

  # Mock hub to return nothing
  cat > "${TEST_DIR}/bin/hub" <<'EOF'
#!/bin/sh
# No output - no open PRs
EOF
  chmod +x "${TEST_DIR}/bin/hub"

  run bash "${GIT_PR_SCRIPT}"
  [ "$status" -eq 0 ]
}
