#!/usr/bin/env bats

# Path to the script being tested
GIT_NUKE_SCRIPT="${BATS_TEST_DIRNAME}/../../bin/git-nuke"

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

@test "git-nuke script exists and is executable" {
  [ -f "${GIT_NUKE_SCRIPT}" ]
  [ -x "${GIT_NUKE_SCRIPT}" ]
}

@test "git-nuke deletes branch locally and on remote" {
  a_git_repository_with_remote_tracking "${TEST_REPO}" "${TEST_REMOTE}"
  cd "${TEST_REPO}"

  # Create and push a feature branch
  git checkout -b feature-to-nuke
  echo "feature" > feature.txt
  git add feature.txt
  git commit -m "Add feature"
  git push origin feature-to-nuke

  # Go back to master
  git checkout master

  # Verify branch exists locally and remotely
  run git branch
  [[ "$output" == *"feature-to-nuke"* ]]
  run git branch -r
  [[ "$output" == *"origin/feature-to-nuke"* ]]

  # Run git-nuke
  run bash "${GIT_NUKE_SCRIPT}" feature-to-nuke
  [ "$status" -eq 0 ]

  # Verify branch is deleted locally
  run git branch
  [[ "$output" != *"feature-to-nuke"* ]]

  # Verify branch is deleted on remote
  run git branch -r
  [[ "$output" != *"origin/feature-to-nuke"* ]]
}

@test "git-nuke deletes local-only branch" {
  a_git_repository_with_remote_tracking "${TEST_REPO}" "${TEST_REMOTE}"
  cd "${TEST_REPO}"

  # Create a local-only branch
  git checkout -b local-only-branch
  echo "local" > local.txt
  git add local.txt
  git commit -m "Local only"
  git checkout master

  # Run git-nuke (push to remote will fail but local delete should work)
  run bash "${GIT_NUKE_SCRIPT}" local-only-branch

  # Local branch should be deleted
  run git branch
  [[ "$output" != *"local-only-branch"* ]]
}
