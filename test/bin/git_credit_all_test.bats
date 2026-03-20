#!/usr/bin/env bats

# Path to the script being tested
GIT_CREDIT_ALL_SCRIPT="${BATS_TEST_DIRNAME}/../../bin/git-credit-all"

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

@test "git-credit-all script exists and is executable" {
  [ -f "${GIT_CREDIT_ALL_SCRIPT}" ]
  [ -x "${GIT_CREDIT_ALL_SCRIPT}" ]
}

@test "git-credit-all changes author of a specific commit" {
  a_real_git_repository_with_branches "${TEST_REPO}"
  cd "${TEST_REPO}"

  # Create a couple of commits
  echo "first" > first.txt
  git add first.txt
  git commit -m "First commit"
  FIRST_HASH=$(git rev-parse HEAD)

  echo "second" > second.txt
  git add second.txt
  git commit -m "Second commit"

  # Change the author of the first commit
  run bash "${GIT_CREDIT_ALL_SCRIPT}" "${FIRST_HASH}" HEAD "Jane Doe" "jane@example.com"
  [ "$status" -eq 0 ]

  # Verify the author was changed on the target commit
  AUTHOR=$(git log --all --format='%an <%ae>' --reverse | grep "Jane Doe")
  [[ "$AUTHOR" == *"Jane Doe <jane@example.com>"* ]]
}

@test "git-credit-all accepts -f flag for force" {
  a_real_git_repository_with_branches "${TEST_REPO}"
  cd "${TEST_REPO}"

  echo "content" > file.txt
  git add file.txt
  git commit -m "Test commit"
  HASH=$(git rev-parse HEAD)

  # Run with -f flag
  run bash "${GIT_CREDIT_ALL_SCRIPT}" -f "${HASH}" HEAD "John Smith" "john@example.com"
  [ "$status" -eq 0 ]
}

@test "git-credit-all fails with invalid commit" {
  a_real_git_repository_with_branches "${TEST_REPO}"
  cd "${TEST_REPO}"

  run bash "${GIT_CREDIT_ALL_SCRIPT}" "invalidhash123"
  [ "$status" -ne 0 ]
  [[ "$output" == *"is not a commit"* ]]
}
