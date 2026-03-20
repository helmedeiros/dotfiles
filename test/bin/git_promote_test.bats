#!/usr/bin/env bats

# Path to the script being tested
GIT_PROMOTE_SCRIPT="${BATS_TEST_DIRNAME}/../../bin/git-promote"

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

@test "git-promote script exists and is executable" {
  [ -f "${GIT_PROMOTE_SCRIPT}" ]
  [ -x "${GIT_PROMOTE_SCRIPT}" ]
}

@test "git-promote pushes local branch to origin" {
  a_git_repository_with_remote_tracking "${TEST_REPO}" "${TEST_REMOTE}"
  cd "${TEST_REPO}"

  # Create a local-only branch
  git checkout -b feature-promote
  echo "feature" > feature.txt
  git add feature.txt
  git commit -m "Add feature"

  # Verify branch does not exist on remote
  run git branch -r
  [[ "$output" != *"origin/feature-promote"* ]]

  # Run git-promote
  run bash "${GIT_PROMOTE_SCRIPT}"
  [ "$status" -eq 0 ]

  # Verify branch now exists on remote
  run git branch -r
  [[ "$output" == *"origin/feature-promote"* ]]
}

@test "git-promote sets up remote and merge config" {
  a_git_repository_with_remote_tracking "${TEST_REPO}" "${TEST_REMOTE}"
  cd "${TEST_REPO}"

  # Create a local branch
  git checkout -b topic-branch
  echo "topic" > topic.txt
  git add topic.txt
  git commit -m "Topic work"

  # Run git-promote
  run bash "${GIT_PROMOTE_SCRIPT}"
  [ "$status" -eq 0 ]

  # Verify remote config is set
  REMOTE=$(git config --get "branch.topic-branch.remote")
  [ "$REMOTE" = "origin" ]

  # Verify merge config is set
  MERGE=$(git config --get "branch.topic-branch.merge")
  [ "$MERGE" = "refs/heads/topic-branch" ]
}

@test "git-promote does not push if branch already exists on remote" {
  a_git_repository_with_remote_tracking "${TEST_REPO}" "${TEST_REMOTE}"
  cd "${TEST_REPO}"

  # Create and push a branch
  git checkout -b already-pushed
  echo "content" > file.txt
  git add file.txt
  git commit -m "Add content"
  git push origin already-pushed

  # Run git-promote (should skip push since remote branch exists)
  run bash "${GIT_PROMOTE_SCRIPT}"
  [ "$status" -eq 0 ]
}
