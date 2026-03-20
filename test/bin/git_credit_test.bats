#!/usr/bin/env bats

# Path to the script being tested
GIT_CREDIT_SCRIPT="${BATS_TEST_DIRNAME}/../../bin/git-credit"

# Load the Object Mother
load "../mothers/test_mother.sh"

setup() {
  TEST_DIR="$(mktemp -d)"
  TEST_REPO="${TEST_DIR}/test-repo"
  ORIGINAL_DIR="$(pwd)"
}

teardown() {
  cd "${ORIGINAL_DIR}"
  rm -rf "${TEST_DIR}"
}

@test "git-credit script exists and is executable" {
  [ -f "${GIT_CREDIT_SCRIPT}" ]
  [ -x "${GIT_CREDIT_SCRIPT}" ]
}

@test "git-credit changes the author of the last commit" {
  a_real_git_repository_with_branches "${TEST_REPO}"
  cd "${TEST_REPO}"

  # Make a commit to credit
  echo "feature" > feature.txt
  git add feature.txt
  git commit -m "Add feature"

  # Run git-credit
  run bash "${GIT_CREDIT_SCRIPT}" "Jane Doe" "jane@example.com"
  [ "$status" -eq 0 ]

  # Verify the author was changed
  AUTHOR=$(git log -1 --pretty=format:'%an <%ae>')
  [ "$AUTHOR" = "Jane Doe <jane@example.com>" ]
}

@test "git-credit preserves the commit message" {
  a_real_git_repository_with_branches "${TEST_REPO}"
  cd "${TEST_REPO}"

  echo "feature" > feature.txt
  git add feature.txt
  git commit -m "My special commit message"

  run bash "${GIT_CREDIT_SCRIPT}" "Jane Doe" "jane@example.com"
  [ "$status" -eq 0 ]

  MSG=$(git log -1 --pretty=%B | head -1)
  [ "$MSG" = "My special commit message" ]
}

@test "git-credit does not change commit count" {
  a_real_git_repository_with_branches "${TEST_REPO}"
  cd "${TEST_REPO}"

  echo "feature" > feature.txt
  git add feature.txt
  git commit -m "Add feature"

  COMMITS_BEFORE=$(git rev-list --count HEAD)

  run bash "${GIT_CREDIT_SCRIPT}" "Jane Doe" "jane@example.com"
  [ "$status" -eq 0 ]

  COMMITS_AFTER=$(git rev-list --count HEAD)
  [ "$COMMITS_BEFORE" -eq "$COMMITS_AFTER" ]
}
