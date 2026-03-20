#!/usr/bin/env bats

# Path to the script being tested
GIT_AMEND_SCRIPT="${BATS_TEST_DIRNAME}/../../bin/git-amend"

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

@test "git-amend script exists and is executable" {
  [ -f "${GIT_AMEND_SCRIPT}" ]
  [ -x "${GIT_AMEND_SCRIPT}" ]
}

@test "git-amend amends staged changes into last commit" {
  a_real_git_repository_with_branches "${TEST_REPO}"
  cd "${TEST_REPO}"

  ORIGINAL_MSG=$(git log -1 --pretty=%B)
  COMMITS_BEFORE=$(git rev-list --count HEAD)

  # Stage a new file
  echo "extra" > extra.txt
  git add extra.txt

  # Run git-amend
  run bash "${GIT_AMEND_SCRIPT}"
  [ "$status" -eq 0 ]

  # Commit count should stay the same (amend, not new commit)
  COMMITS_AFTER=$(git rev-list --count HEAD)
  [ "$COMMITS_AFTER" -eq "$COMMITS_BEFORE" ]

  # Commit message should be preserved
  NEW_MSG=$(git log -1 --pretty=%B)
  [ "$ORIGINAL_MSG" = "$NEW_MSG" ]

  # The file should be in the commit
  run git show --name-only --pretty=format:'' HEAD
  [[ "$output" == *"extra.txt"* ]]
}

@test "git-amend preserves the original commit message" {
  a_real_git_repository_with_branches "${TEST_REPO}"
  cd "${TEST_REPO}"

  ORIGINAL_MSG=$(git log -1 --pretty=%B)

  echo "more" > more.txt
  git add more.txt

  run bash "${GIT_AMEND_SCRIPT}"
  [ "$status" -eq 0 ]

  AFTER_MSG=$(git log -1 --pretty=%B)
  [ "$ORIGINAL_MSG" = "$AFTER_MSG" ]
}
