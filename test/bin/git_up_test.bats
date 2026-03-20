#!/usr/bin/env bats

# Path to the script being tested
GIT_UP_SCRIPT="${BATS_TEST_DIRNAME}/../../bin/git-up"

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

@test "git-up script exists and is executable" {
  [ -f "${GIT_UP_SCRIPT}" ]
  [ -x "${GIT_UP_SCRIPT}" ]
}

@test "git-up pulls and shows log" {
  a_git_repository_with_remote_tracking "${TEST_REPO}" "${TEST_REMOTE}"

  # Add a commit to the remote via a second clone
  CLONE_DIR="${TEST_DIR}/clone"
  git clone -b master "${TEST_REMOTE}" "${CLONE_DIR}"
  cd "${CLONE_DIR}"
  git config user.name "Test User"
  git config user.email "test@example.com"
  echo "remote change" > remote.txt
  git add remote.txt
  git commit -m "Remote commit"
  git push origin master

  # Now pull from our test repo
  cd "${TEST_REPO}"

  run bash "${GIT_UP_SCRIPT}"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Log:"* ]]
  [[ "$output" == *"Remote commit"* ]]
}

@test "git-up shows log when already up to date" {
  a_git_repository_with_remote_tracking "${TEST_REPO}" "${TEST_REMOTE}"
  cd "${TEST_REPO}"

  run bash "${GIT_UP_SCRIPT}"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Log:"* ]]
}
