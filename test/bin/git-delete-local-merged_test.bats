#!/usr/bin/env bats

# Path to the script being tested
GIT_DELETE_SCRIPT="${BATS_TEST_DIRNAME}/../../bin/git-delete-local-merged"

# Load the Object Mother
load "../mothers/test_mother.sh"

# Setup function that runs before each test
setup() {
  # Create a temporary directory for test files
  TEST_DIR="$(mktemp -d)"

  # Create an isolated git repository for testing
  TEST_REPO="${TEST_DIR}/test-repo"

  # Save the current directory to return to it later
  ORIGINAL_DIR="$(pwd)"
}

# Teardown function that runs after each test
teardown() {
  # Return to the original directory
  cd "${ORIGINAL_DIR}"

  # Clean up the temporary directory
  rm -rf "${TEST_DIR}"
}

# Test that the script exists and is executable
@test "git-delete-local-merged script exists and is executable" {
  [ -f "${GIT_DELETE_SCRIPT}" ]
  [ -x "${GIT_DELETE_SCRIPT}" ]
}

# Test deleting merged branches in a standard scenario
@test "git-delete-local-merged deletes merged branches but not unmerged ones" {
  # Set up repository with merged and unmerged branches
  a_git_repository_with_merged_branches "${TEST_REPO}"

  # Verify initial state - should have feature-1, feature-2, feature-unmerged, and master
  cd "${TEST_REPO}"
  run git branch
  [ "$status" -eq 0 ]
  [[ "$output" == *"feature-1"* ]]
  [[ "$output" == *"feature-2"* ]]
  [[ "$output" == *"feature-unmerged"* ]]
  [[ "$output" == *"master"* ]]

  # Run the delete script
  run bash "${GIT_DELETE_SCRIPT}"

  # Check exit status (should succeed)
  [ "$status" -eq 0 ]

  # Verify merged branches were deleted
  run git branch
  [ "$status" -eq 0 ]
  [[ "$output" != *"feature-1"* ]]
  [[ "$output" != *"feature-2"* ]]

  # Verify unmerged branch still exists
  [[ "$output" == *"feature-unmerged"* ]]

  # Verify master still exists
  [[ "$output" == *"master"* ]]
}

# Test that master branch is never deleted even if technically merged
@test "git-delete-local-merged never deletes master branch" {
  # Set up repository with only master
  a_git_repository_with_only_master "${TEST_REPO}"

  cd "${TEST_REPO}"

  # Create a feature branch, merge it, then go back to feature branch
  git checkout -b feature-temp
  echo "temp" > temp.txt
  git add temp.txt
  git commit -m "Temp commit"
  git checkout master
  git merge feature-temp

  # Now we're on master, which should never be deleted
  run bash "${GIT_DELETE_SCRIPT}"
  [ "$status" -eq 0 ]

  # Verify master still exists
  run git branch
  [[ "$output" == *"master"* ]]
}

# Test that the current branch is never deleted (marked with *)
@test "git-delete-local-merged never deletes current branch" {
  # Set up repository where we're on a merged branch
  a_git_repository_on_merged_branch "${TEST_REPO}"

  cd "${TEST_REPO}"

  # Verify we're on feature-merged
  run git branch
  [[ "$output" == *"* feature-merged"* ]]

  # Run the delete script
  run bash "${GIT_DELETE_SCRIPT}"
  [ "$status" -eq 0 ]

  # Verify the current branch still exists (shouldn't delete branch we're on)
  run git branch
  [[ "$output" == *"feature-merged"* ]]
}

# Test behavior when no branches need to be deleted
@test "git-delete-local-merged handles no merged branches gracefully" {
  # Set up repository with only master branch
  a_git_repository_with_only_master "${TEST_REPO}"

  cd "${TEST_REPO}"

  # Create an unmerged branch
  git checkout -b feature-unmerged
  echo "unmerged" > unmerged.txt
  git add unmerged.txt
  git commit -m "Unmerged work"
  git checkout master

  # Run the delete script
  run bash "${GIT_DELETE_SCRIPT}"

  # Should succeed (even if no branches deleted)
  [ "$status" -eq 0 ]

  # Verify both branches still exist
  run git branch
  [[ "$output" == *"master"* ]]
  [[ "$output" == *"feature-unmerged"* ]]
}

# Test with branches that have special characters in names
@test "git-delete-local-merged handles branch names with slashes" {
  # Set up repository with special branch names
  a_git_repository_with_special_branch_names "${TEST_REPO}"

  cd "${TEST_REPO}"

  # Verify initial state
  run git branch
  [[ "$output" == *"bugfix/issue-123"* ]]
  [[ "$output" == *"feature/user-auth"* ]]

  # Run the delete script
  run bash "${GIT_DELETE_SCRIPT}"
  [ "$status" -eq 0 ]

  # Verify merged branches with slashes were deleted
  run git branch
  [[ "$output" != *"bugfix/issue-123"* ]]
  [[ "$output" != *"feature/user-auth"* ]]

  # Verify master still exists
  [[ "$output" == *"master"* ]]
}

# Test behavior in a repository with main instead of master
@test "git-delete-local-merged preserves main branch like master" {
  # Set up repository with main as primary branch
  a_git_repository_with_main_branch "${TEST_REPO}"

  cd "${TEST_REPO}"

  # Create and merge a feature branch
  git checkout -b feature-test
  echo "test" > test.txt
  git add test.txt
  git commit -m "Test commit"
  git checkout main
  git merge feature-test

  # Run the delete script (should delete feature-test but not main)
  run bash "${GIT_DELETE_SCRIPT}"
  [ "$status" -eq 0 ]

  # Verify main still exists
  run git branch
  [[ "$output" == *"main"* ]]

  # Note: The script only protects 'master', not 'main'
  # This test documents current behavior
  # feature-test should be deleted
  [[ "$output" != *"feature-test"* ]]
}

# Test that the script works from subdirectories
@test "git-delete-local-merged works from subdirectory of repository" {
  # Set up repository with merged branches
  a_git_repository_with_merged_branches "${TEST_REPO}"

  # Create and enter a subdirectory
  cd "${TEST_REPO}"
  mkdir -p subdir/nested
  cd subdir/nested

  # Run the delete script from subdirectory
  run bash "${GIT_DELETE_SCRIPT}"
  [ "$status" -eq 0 ]

  # Verify branches were deleted
  cd "${TEST_REPO}"
  run git branch
  [[ "$output" != *"feature-1"* ]]
  [[ "$output" != *"feature-2"* ]]
  [[ "$output" == *"feature-unmerged"* ]]
}

# Test error handling when not in a git repository
@test "git-delete-local-merged handles non-git directory gracefully" {
  # Create a non-git directory
  mkdir -p "${TEST_DIR}/not-a-repo"
  cd "${TEST_DIR}/not-a-repo"

  # Run the delete script
  run bash "${GIT_DELETE_SCRIPT}"

  # Should exit successfully (doesn't crash) but prints error to stderr
  [ "$status" -eq 0 ]

  # Output should contain git error message
  [[ "$output" == *"fatal"* ]] || [[ "$output" == *"not a git repository"* ]]
}

# Test with multiple merged branches to ensure all are deleted
@test "git-delete-local-merged deletes multiple merged branches at once" {
  # Set up repository
  a_real_git_repository_with_branches "${TEST_REPO}"

  cd "${TEST_REPO}"

  # Create and merge 5 feature branches
  for i in {1..5}; do
    git checkout -b "feature-${i}"
    echo "Feature ${i}" > "feature-${i}.txt"
    git add "feature-${i}.txt"
    git commit -m "Add feature ${i}"
    git checkout master
    git merge "feature-${i}"
  done

  # Verify all branches exist
  run git branch
  for i in {1..5}; do
    [[ "$output" == *"feature-${i}"* ]]
  done

  # Run the delete script
  run bash "${GIT_DELETE_SCRIPT}"
  [ "$status" -eq 0 ]

  # Verify all merged branches were deleted
  run git branch
  for i in {1..5}; do
    [[ "$output" != *"feature-${i}"* ]]
  done

  # Verify master still exists
  [[ "$output" == *"master"* ]]
}

# Test that partially merged branches are not deleted
@test "git-delete-local-merged does not delete branches with unmerged commits" {
  # Set up repository
  a_real_git_repository_with_branches "${TEST_REPO}"

  cd "${TEST_REPO}"

  # Create a branch with commits, merge some but not all
  git checkout -b feature-partial
  echo "Commit 1" > file1.txt
  git add file1.txt
  git commit -m "First commit"

  # Merge this commit
  git checkout master
  git merge feature-partial

  # Add another commit to feature-partial that's not merged
  git checkout feature-partial
  echo "Commit 2" > file2.txt
  git add file2.txt
  git commit -m "Second commit - not merged"

  # Go back to master
  git checkout master

  # Run the delete script
  run bash "${GIT_DELETE_SCRIPT}"
  [ "$status" -eq 0 ]

  # The branch should NOT be deleted because it has unmerged commits
  run git branch
  [[ "$output" == *"feature-partial"* ]]
}
