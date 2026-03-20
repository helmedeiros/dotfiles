#!/usr/bin/env bats

# Path to the script being tested
GIT_ALL_SCRIPT="${BATS_TEST_DIRNAME}/../../bin/git-all"

# Load the Object Mother
load "../mothers/test_mother.sh"

# Setup function that runs before each test
setup() {
  TEST_DIR="$(mktemp -d)"
  TEST_REPO="${TEST_DIR}/test-repo"
  ORIGINAL_DIR="$(pwd)"
}

# Teardown function that runs after each test
teardown() {
  cd "${ORIGINAL_DIR}"
  rm -rf "${TEST_DIR}"
}

@test "git-all script exists and is executable" {
  [ -f "${GIT_ALL_SCRIPT}" ]
  [ -x "${GIT_ALL_SCRIPT}" ]
}

@test "git-all stages all untracked files" {
  a_real_git_repository_with_branches "${TEST_REPO}"
  cd "${TEST_REPO}"

  # Create untracked files
  echo "new file" > newfile.txt
  echo "another" > another.txt

  # Verify they are untracked
  run git status --porcelain
  [[ "$output" == *"?? newfile.txt"* ]]
  [[ "$output" == *"?? another.txt"* ]]

  # Run git-all
  run bash "${GIT_ALL_SCRIPT}"
  [ "$status" -eq 0 ]

  # Verify all files are staged
  run git status --porcelain
  [[ "$output" == *"A  newfile.txt"* ]]
  [[ "$output" == *"A  another.txt"* ]]
}

@test "git-all stages modified files" {
  a_real_git_repository_with_branches "${TEST_REPO}"
  cd "${TEST_REPO}"

  # Modify an existing tracked file
  echo "modified content" >> README.md

  run git status --porcelain
  [[ "$output" == *"M README.md"* ]]

  run bash "${GIT_ALL_SCRIPT}"
  [ "$status" -eq 0 ]

  run git status --porcelain
  [[ "$output" == *"M  README.md"* ]]
}

@test "git-all stages deleted files" {
  a_real_git_repository_with_branches "${TEST_REPO}"
  cd "${TEST_REPO}"

  rm README.md

  run bash "${GIT_ALL_SCRIPT}"
  [ "$status" -eq 0 ]

  run git status --porcelain
  [[ "$output" == *"D  README.md"* ]]
}
