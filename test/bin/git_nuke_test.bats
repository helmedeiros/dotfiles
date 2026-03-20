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

@test "git-nuke deletes branch locally and on remote with --force" {
  a_git_repository_with_remote_tracking "${TEST_REPO}" "${TEST_REMOTE}"
  cd "${TEST_REPO}"

  git checkout -b feature-to-nuke
  echo "feature" > feature.txt
  git add feature.txt
  git commit -m "Add feature"
  git push origin feature-to-nuke

  git checkout master

  run git branch
  [[ "$output" == *"feature-to-nuke"* ]]
  run git branch -r
  [[ "$output" == *"origin/feature-to-nuke"* ]]

  run bash "${GIT_NUKE_SCRIPT}" --force feature-to-nuke
  [ "$status" -eq 0 ]

  run git branch
  [[ "$output" != *"feature-to-nuke"* ]]

  run git branch -r
  [[ "$output" != *"origin/feature-to-nuke"* ]]
}

@test "git-nuke deletes branch with -f short flag" {
  a_git_repository_with_remote_tracking "${TEST_REPO}" "${TEST_REMOTE}"
  cd "${TEST_REPO}"

  git checkout -b short-flag-branch
  echo "content" > file.txt
  git add file.txt
  git commit -m "Add file"
  git push origin short-flag-branch
  git checkout master

  run bash "${GIT_NUKE_SCRIPT}" -f short-flag-branch
  [ "$status" -eq 0 ]

  run git branch
  [[ "$output" != *"short-flag-branch"* ]]
}

@test "git-nuke aborts without confirmation" {
  a_git_repository_with_remote_tracking "${TEST_REPO}" "${TEST_REMOTE}"
  cd "${TEST_REPO}"

  git checkout -b keep-this-branch
  echo "content" > file.txt
  git add file.txt
  git commit -m "Add file"
  git push origin keep-this-branch
  git checkout master

  # Answer "n" to the prompt
  run bash -c "echo 'n' | bash '${GIT_NUKE_SCRIPT}' keep-this-branch"
  [ "$status" -ne 0 ]
  [[ "$output" == *"Aborted"* ]]

  # Branch should still exist
  run git branch
  [[ "$output" == *"keep-this-branch"* ]]
}

@test "git-nuke proceeds with y confirmation" {
  a_git_repository_with_remote_tracking "${TEST_REPO}" "${TEST_REMOTE}"
  cd "${TEST_REPO}"

  git checkout -b confirmed-branch
  echo "content" > file.txt
  git add file.txt
  git commit -m "Add file"
  git push origin confirmed-branch
  git checkout master

  run bash -c "echo 'y' | bash '${GIT_NUKE_SCRIPT}' confirmed-branch"
  [ "$status" -eq 0 ]

  run git branch
  [[ "$output" != *"confirmed-branch"* ]]
}

@test "git-nuke shows usage when no branch given" {
  run bash "${GIT_NUKE_SCRIPT}"
  [ "$status" -ne 0 ]
  [[ "$output" == *"Usage"* ]]
}

@test "git-nuke deletes local-only branch with --force" {
  a_git_repository_with_remote_tracking "${TEST_REPO}" "${TEST_REMOTE}"
  cd "${TEST_REPO}"

  git checkout -b local-only-branch
  echo "local" > local.txt
  git add local.txt
  git commit -m "Local only"
  git checkout master

  run bash "${GIT_NUKE_SCRIPT}" -f local-only-branch

  run git branch
  [[ "$output" != *"local-only-branch"* ]]
}
