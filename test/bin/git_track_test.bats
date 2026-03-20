#!/usr/bin/env bats

# Path to the script being tested
GIT_TRACK_SCRIPT="${BATS_TEST_DIRNAME}/../../bin/git-track"

# Load the Object Mother
load "../mothers/test_mother.sh"

setup() {
  TEST_DIR="$(mktemp -d)"
  TEST_REPO="${TEST_DIR}/test-repo"
  TEST_REMOTE="${TEST_DIR}/test-remote"
  ORIGINAL_DIR="$(pwd)"
}

teardown() {
  cd "${ORIGINAL_DIR}"
  rm -rf "${TEST_DIR}"
}

@test "git-track script exists and is executable" {
  [ -f "${GIT_TRACK_SCRIPT}" ]
  [ -x "${GIT_TRACK_SCRIPT}" ]
}

@test "git-track sets upstream to origin/branch" {
  a_git_repository_with_remote_tracking "${TEST_REPO}" "${TEST_REMOTE}"
  cd "${TEST_REPO}"

  # Create a branch locally and push it (with tracking so we can unset it)
  git checkout -b feature-branch
  echo "feature" > feature.txt
  git add feature.txt
  git commit -m "Add feature"
  git push -u origin feature-branch

  # Unset the upstream tracking
  git branch --unset-upstream feature-branch

  # Run git-track
  run bash "${GIT_TRACK_SCRIPT}"
  [ "$status" -eq 0 ]

  # Verify upstream is now set
  run git rev-parse --abbrev-ref feature-branch@{upstream}
  [ "$status" -eq 0 ]
  [[ "$output" == "origin/feature-branch" ]]
}

@test "git-track uses current branch name" {
  a_git_repository_with_remote_tracking "${TEST_REPO}" "${TEST_REMOTE}"
  cd "${TEST_REPO}"

  # Create and push a branch with tracking, then unset
  git checkout -b my-feature
  echo "feature" > feature.txt
  git add feature.txt
  git commit -m "Add feature"
  git push -u origin my-feature

  # Unset upstream
  git branch --unset-upstream my-feature

  # Run git-track
  run bash "${GIT_TRACK_SCRIPT}"
  [ "$status" -eq 0 ]

  # Verify upstream matches the current branch name
  UPSTREAM=$(git rev-parse --abbrev-ref my-feature@{upstream})
  [ "$UPSTREAM" = "origin/my-feature" ]
}
