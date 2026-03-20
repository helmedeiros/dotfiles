#!/usr/bin/env bats

# Path to the script being tested
GIT_RANK_SCRIPT="${BATS_TEST_DIRNAME}/../../bin/git-rank-contributors"

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

@test "git-rank-contributors script exists and is executable" {
  [ -f "${GIT_RANK_SCRIPT}" ]
  [ -x "${GIT_RANK_SCRIPT}" ]
}

@test "git-rank-contributors lists contributors" {
  a_real_git_repository_with_branches "${TEST_REPO}"
  cd "${TEST_REPO}"

  # Add some commits
  echo "feature1" > f1.txt
  git add f1.txt
  git commit -m "Add feature 1"

  echo "feature2" > f2.txt
  git add f2.txt
  git commit -m "Add feature 2"

  run ruby "${GIT_RANK_SCRIPT}"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Test User"* ]]
}

@test "git-rank-contributors verbose mode shows line counts" {
  a_real_git_repository_with_branches "${TEST_REPO}"
  cd "${TEST_REPO}"

  echo "line1" > file.txt
  git add file.txt
  git commit -m "Add file"

  run ruby "${GIT_RANK_SCRIPT}" -v
  [ "$status" -eq 0 ]
  [[ "$output" == *"lines of diff"* ]]
}

@test "git-rank-contributors ranks by diff size" {
  a_real_git_repository_with_branches "${TEST_REPO}"
  cd "${TEST_REPO}"

  # Create commits as different authors
  git config user.name "Alice"
  for i in $(seq 1 10); do
    echo "line $i" >> big_file.txt
  done
  git add big_file.txt
  git commit -m "Alice big change"

  git config user.name "Bob"
  echo "small" > small.txt
  git add small.txt
  git commit -m "Bob small change"

  run ruby "${GIT_RANK_SCRIPT}" -v
  [ "$status" -eq 0 ]

  # Alice should appear before Bob (more lines)
  ALICE_LINE=$(echo "$output" | grep -n "Alice" | head -1 | cut -d: -f1)
  BOB_LINE=$(echo "$output" | grep -n "Bob" | head -1 | cut -d: -f1)
  [ "$ALICE_LINE" -lt "$BOB_LINE" ]
}
