#!/usr/bin/env bats

# Path to the script being tested
GIT_WTF_SCRIPT="${BATS_TEST_DIRNAME}/../../bin/git-wtf"

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

@test "git-wtf script exists and is executable" {
  [ -f "${GIT_WTF_SCRIPT}" ]
  [ -x "${GIT_WTF_SCRIPT}" ]
}

@test "git-wtf shows help with --help" {
  run ruby "${GIT_WTF_SCRIPT}" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
  [[ "$output" == *"git wtf"* ]]
}

@test "git-wtf shows key with --key" {
  a_git_repository_with_remote_tracking "${TEST_REPO}" "${TEST_REMOTE}"
  cd "${TEST_REPO}"

  run ruby "${GIT_WTF_SCRIPT}" --key
  [ "$status" -eq 0 ]
  [[ "$output" == *"KEY:"* ]]
}

@test "git-wtf shows local branch info" {
  a_git_repository_with_remote_tracking "${TEST_REPO}" "${TEST_REMOTE}"
  cd "${TEST_REPO}"

  run ruby "${GIT_WTF_SCRIPT}" -s
  [ "$status" -eq 0 ]
  [[ "$output" == *"Local branch:"* ]]
  [[ "$output" == *"master"* ]]
}

@test "git-wtf shows remote branch info" {
  a_git_repository_with_remote_tracking "${TEST_REPO}" "${TEST_REMOTE}"
  cd "${TEST_REPO}"

  run ruby "${GIT_WTF_SCRIPT}" -s
  [ "$status" -eq 0 ]
  [[ "$output" == *"Remote branch:"* ]]
}

@test "git-wtf shows in sync when no unpushed changes" {
  a_git_repository_with_remote_tracking "${TEST_REPO}" "${TEST_REMOTE}"
  cd "${TEST_REPO}"

  run ruby "${GIT_WTF_SCRIPT}" -s
  [ "$status" -eq 0 ]
  [[ "$output" == *"in sync"* ]]
}

@test "git-wtf shows NOT in sync when commits ahead" {
  a_git_repository_with_remote_tracking "${TEST_REPO}" "${TEST_REMOTE}"
  cd "${TEST_REPO}"

  # Add unpushed commit
  echo "new" > new.txt
  git add new.txt
  git commit -m "Unpushed commit"

  run ruby "${GIT_WTF_SCRIPT}" -s
  [ "$status" -eq 0 ]
  [[ "$output" == *"NOT in sync"* ]]
}

@test "git-wtf dumps config with --dump-config" {
  a_git_repository_with_remote_tracking "${TEST_REPO}" "${TEST_REMOTE}"
  cd "${TEST_REPO}"

  run ruby "${GIT_WTF_SCRIPT}" --dump-config
  [ "$status" -eq 0 ]
  [[ "$output" == *"integration-branches"* ]]
  [[ "$output" == *"max_commits"* ]]
}

@test "git-wtf fails for unknown branch" {
  a_git_repository_with_remote_tracking "${TEST_REPO}" "${TEST_REMOTE}"
  cd "${TEST_REPO}"

  run ruby "${GIT_WTF_SCRIPT}" nonexistent-branch
  [ "$status" -ne 0 ]
  [[ "$output" == *"Error"* ]]
}
