#!/usr/bin/env bats

# Path to the script being tested
GIT_UNDO_SCRIPT="${BATS_TEST_DIRNAME}/../../bin/git-undo"

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
@test "git-undo script exists and is executable" {
  [ -f "${GIT_UNDO_SCRIPT}" ]
  [ -x "${GIT_UNDO_SCRIPT}" ]
}

# Test undoing last commit but keeping changes staged
@test "git-undo undoes last commit but keeps changes staged" {
  # Create a repository with commits
  a_real_git_repository_with_branches "${TEST_REPO}"

  cd "${TEST_REPO}"

  # Make a second commit
  echo "New feature" > feature.txt
  git add feature.txt
  git commit -m "Add feature"

  # Get the commit count before undo
  COMMITS_BEFORE=$(git rev-list --count HEAD)

  # Run git-undo
  run bash "${GIT_UNDO_SCRIPT}"
  [ "$status" -eq 0 ]

  # Verify the commit was undone
  COMMITS_AFTER=$(git rev-list --count HEAD)
  [ "$COMMITS_AFTER" -eq $((COMMITS_BEFORE - 1)) ]

  # Verify the changes are still staged
  run git status --porcelain
  [[ "$output" == *"A  feature.txt"* ]]
}

# Test that working directory changes are preserved
@test "git-undo preserves working directory changes" {
  # Create a repository
  a_real_git_repository_with_branches "${TEST_REPO}"

  cd "${TEST_REPO}"

  # Make a commit
  echo "Committed content" > committed.txt
  git add committed.txt
  git commit -m "Add committed file"

  # Make an unstaged change
  echo "Unstaged change" > uncommitted.txt

  # Run git-undo
  run bash "${GIT_UNDO_SCRIPT}"
  [ "$status" -eq 0 ]

  # Verify the unstaged file still exists
  [ -f uncommitted.txt ]
  run cat uncommitted.txt
  [[ "$output" == "Unstaged change" ]]

  # Verify the previously committed file is now staged
  run git status --porcelain
  [[ "$output" == *"A  committed.txt"* ]]
  [[ "$output" == *"?? uncommitted.txt"* ]]
}

# Test with only one commit in the repository
@test "git-undo works when there is only one commit" {
  # Create a repository with just one commit
  a_git_repository_with_only_master "${TEST_REPO}"

  cd "${TEST_REPO}"

  # Verify we have exactly 1 commit
  COMMITS=$(git rev-list --count HEAD)
  [ "$COMMITS" -eq 1 ]

  # Run git-undo
  run bash "${GIT_UNDO_SCRIPT}"

  # This should fail because there's no parent commit
  # git reset --soft HEAD^ will error when there's no parent
  [ "$status" -ne 0 ]
  [[ "$output" == *"fatal"* ]] || [[ "$output" == *"ambiguous argument"* ]]
}

# Test undoing multiple commits in sequence
@test "git-undo can be run multiple times to undo multiple commits" {
  # Create a repository
  a_real_git_repository_with_branches "${TEST_REPO}"

  cd "${TEST_REPO}"

  # Create multiple commits
  for i in {1..3}; do
    echo "Feature ${i}" > "feature${i}.txt"
    git add "feature${i}.txt"
    git commit -m "Add feature ${i}"
  done

  INITIAL_COMMITS=$(git rev-list --count HEAD)

  # Undo first commit
  run bash "${GIT_UNDO_SCRIPT}"
  [ "$status" -eq 0 ]

  # Verify one commit was undone and file is staged
  COMMITS_AFTER_FIRST=$(git rev-list --count HEAD)
  [ "$COMMITS_AFTER_FIRST" -eq $((INITIAL_COMMITS - 1)) ]
  run git status --porcelain
  [[ "$output" == *"A  feature3.txt"* ]]

  # Commit the staged changes to clean up
  git commit -m "Re-add feature 3"

  # Undo second commit
  run bash "${GIT_UNDO_SCRIPT}"
  [ "$status" -eq 0 ]

  # Verify another commit was undone
  COMMITS_AFTER_SECOND=$(git rev-list --count HEAD)
  [ "$COMMITS_AFTER_SECOND" -eq $((INITIAL_COMMITS - 1)) ]
}

# Test that git-undo doesn't affect other branches
@test "git-undo only affects the current branch" {
  # Create a repository with branches
  a_git_repository_with_merged_branches "${TEST_REPO}"

  cd "${TEST_REPO}"

  # Get the current commit on master
  git checkout master
  MASTER_COMMIT_BEFORE=$(git rev-parse HEAD)
  MASTER_COMMITS_BEFORE=$(git rev-list --count HEAD)

  # Switch to feature-unmerged branch
  git checkout feature-unmerged

  # Get commit count on this branch
  FEATURE_COMMITS=$(git rev-list --count HEAD)

  # Run git-undo
  run bash "${GIT_UNDO_SCRIPT}"
  [ "$status" -eq 0 ]

  # Verify this branch has one less commit
  FEATURE_COMMITS_AFTER=$(git rev-list --count HEAD)
  [ "$FEATURE_COMMITS_AFTER" -eq $((FEATURE_COMMITS - 1)) ]

  # Switch to master and verify it's unchanged
  git checkout master
  MASTER_COMMIT_AFTER=$(git rev-parse HEAD)
  MASTER_COMMITS_AFTER=$(git rev-list --count HEAD)

  # The master branch should be exactly the same
  [ "$MASTER_COMMIT_BEFORE" = "$MASTER_COMMIT_AFTER" ]
  [ "$MASTER_COMMITS_BEFORE" -eq "$MASTER_COMMITS_AFTER" ]
}

# Test git-undo with a merge commit
@test "git-undo can undo a merge commit" {
  # Create a simple repository
  a_real_git_repository_with_branches "${TEST_REPO}"

  cd "${TEST_REPO}"

  # Create a feature branch and merge it
  git checkout -b feature-merge
  echo "Feature" > feature.txt
  git add feature.txt
  git commit -m "Add feature"

  git checkout master
  git merge --no-ff feature-merge -m "Merge feature"

  # Get the last commit hash (should be a merge commit)
  LAST_COMMIT_HASH=$(git rev-parse HEAD)
  LAST_COMMIT_MSG=$(git log -1 --pretty=%B)

  # Verify it's a merge commit (has 2 parents)
  PARENT_COUNT=$(git cat-file -p HEAD | grep "^parent" | wc -l)
  [ "$PARENT_COUNT" -eq 2 ]

  # Run git-undo
  run bash "${GIT_UNDO_SCRIPT}"
  [ "$status" -eq 0 ]

  # Verify HEAD moved back (not at merge commit anymore)
  NEW_HEAD=$(git rev-parse HEAD)
  [ "$LAST_COMMIT_HASH" != "$NEW_HEAD" ]

  # Verify the new last commit message is different (not the merge message)
  NEW_LAST_COMMIT_MSG=$(git log -1 --pretty=%B)
  [ "$LAST_COMMIT_MSG" != "$NEW_LAST_COMMIT_MSG" ]

  # Verify that the feature.txt file is now staged
  run git status --porcelain
  [[ "$output" == *"feature.txt"* ]]
}

# Test that staged changes before undo remain staged after undo
@test "git-undo preserves existing staged changes" {
  # Create a repository
  a_real_git_repository_with_branches "${TEST_REPO}"

  cd "${TEST_REPO}"

  # Make a commit
  echo "Commit 1" > file1.txt
  git add file1.txt
  git commit -m "Add file1"

  # Stage a new file (but don't commit)
  echo "Staged content" > staged.txt
  git add staged.txt

  # Make another commit
  echo "Commit 2" > file2.txt
  git add file2.txt
  git commit -m "Add file2"

  # Run git-undo
  run bash "${GIT_UNDO_SCRIPT}"
  [ "$status" -eq 0 ]

  # Both staged.txt and file2.txt should be staged now
  run git status --porcelain
  [[ "$output" == *"A  staged.txt"* ]]
  [[ "$output" == *"A  file2.txt"* ]]
}

# Test running git-undo outside a git repository
@test "git-undo fails gracefully when not in a git repository" {
  # Create a non-git directory
  mkdir -p "${TEST_DIR}/not-a-repo"
  cd "${TEST_DIR}/not-a-repo"

  # Run git-undo
  run bash "${GIT_UNDO_SCRIPT}"

  # Should fail with git error
  [ "$status" -ne 0 ]
  [[ "$output" == *"fatal"* ]] || [[ "$output" == *"not a git repository"* ]]
}

# Test git-undo works from subdirectory
@test "git-undo works from a subdirectory of the repository" {
  # Create a repository
  a_real_git_repository_with_branches "${TEST_REPO}"

  cd "${TEST_REPO}"

  # Make a commit
  echo "Feature" > feature.txt
  git add feature.txt
  git commit -m "Add feature"

  # Create and enter subdirectory
  mkdir -p subdir/nested
  cd subdir/nested

  COMMITS_BEFORE=$(git rev-list --count HEAD)

  # Run git-undo from subdirectory
  run bash "${GIT_UNDO_SCRIPT}"
  [ "$status" -eq 0 ]

  # Verify the commit was undone
  COMMITS_AFTER=$(git rev-list --count HEAD)
  [ "$COMMITS_AFTER" -eq $((COMMITS_BEFORE - 1)) ]

  # Verify changes are staged
  run git status --porcelain
  [[ "$output" == *"A  feature.txt"* ]]
}

# Test that file contents are exactly as they were before the commit
@test "git-undo restores exact file contents that were committed" {
  # Create a repository
  a_real_git_repository_with_branches "${TEST_REPO}"

  cd "${TEST_REPO}"

  # Create a file with specific content
  cat > complex.txt <<EOF
Line 1: Original
Line 2: Modified
Line 3: Special chars: !@#$%^&*()
Line 4: Unicode: 你好 🎉
EOF

  git add complex.txt
  git commit -m "Add complex file"

  # Run git-undo
  run bash "${GIT_UNDO_SCRIPT}"
  [ "$status" -eq 0 ]

  # Verify the file still exists with exact content
  [ -f complex.txt ]

  run cat complex.txt
  [[ "$output" == *"Line 1: Original"* ]]
  [[ "$output" == *"Line 3: Special chars: !@#$%^&*()"* ]]
  [[ "$output" == *"Line 4: Unicode: 你好 🎉"* ]]

  # Verify it's staged
  run git status --porcelain
  [[ "$output" == *"A  complex.txt"* ]]
}
