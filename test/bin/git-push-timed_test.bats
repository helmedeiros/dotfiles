#!/usr/bin/env bats

# Path to the script being tested
GIT_PUSH_TIMED_SCRIPT="${BATS_TEST_DIRNAME}/../../bin/git-push-timed"

# Load the Object Mother
load "../mothers/test_mother.sh"

# Setup function that runs before each test
setup() {
  # Create a temporary directory for test files
  TEST_DIR="$(mktemp -d)"

  # Create an isolated git repository for testing
  TEST_REPO="${TEST_DIR}/test-repo"
  TEST_REMOTE="${TEST_DIR}/test-remote"

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
@test "git-push-timed script exists and is executable" {
  [ -f "${GIT_PUSH_TIMED_SCRIPT}" ]
  [ -x "${GIT_PUSH_TIMED_SCRIPT}" ]
}

# Test showing help message with -h
@test "git-push-timed -h shows help message" {
  run bash "${GIT_PUSH_TIMED_SCRIPT}" -h
  [ "$status" -eq 0 ]
  [[ "$output" == *"DESCRIPTION"* ]]
  [[ "$output" == *"USAGE"* ]]
  [[ "$output" == *"OPTIONS"* ]]
  [[ "$output" == *"EXAMPLES"* ]]
}

# Test showing help message with --help
@test "git-push-timed --help shows help message" {
  run bash "${GIT_PUSH_TIMED_SCRIPT}" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"git-push-timed"* ]]
  [[ "$output" == *"--dry-run"* ]]
}

# Test running outside a git repository
@test "git-push-timed fails when not in a git repository" {
  # Create a non-git directory
  mkdir -p "${TEST_DIR}/not-a-repo"
  cd "${TEST_DIR}/not-a-repo"

  # Run git-push-timed
  run bash "${GIT_PUSH_TIMED_SCRIPT}"

  # Should fail with git error
  [ "$status" -ne 0 ]
  [[ "$output" == *"Not a git repository"* ]]
}

# Test when there are no commits to push
@test "git-push-timed handles no commits to push gracefully" {
  # Create a repository with remote
  a_git_repository_with_remote_tracking "${TEST_REPO}" "${TEST_REMOTE}"

  cd "${TEST_REPO}"

  # Run git-push-timed (no commits ahead of remote)
  run bash "${GIT_PUSH_TIMED_SCRIPT}"
  [ "$status" -eq 0 ]
  [[ "$output" == *"No commits to push"* ]] || [[ "$output" == *"up to date"* ]]
}

# Test when there are commits to push (dry-run)
@test "git-push-timed --dry-run shows commits without pushing" {
  # Create a repository with remote and unpushed commits
  a_git_repository_with_unpushed_commits "${TEST_REPO}" "${TEST_REMOTE}"

  cd "${TEST_REPO}"

  # Run in dry-run mode
  run bash "${GIT_PUSH_TIMED_SCRIPT}" --dry-run
  [ "$status" -eq 0 ]

  # Should show dry-run mode
  [[ "$output" == *"DRY RUN"* ]]
  [[ "$output" == *"Would push"* ]]

  # Verify commits were NOT actually pushed
  cd "${TEST_REMOTE}"
  REMOTE_COMMITS=$(git rev-list --count HEAD)
  [ "$REMOTE_COMMITS" -eq 1 ]  # Still only has the initial commit
}

# Test with no remote tracking branch
@test "git-push-timed fails when branch has no remote tracking" {
  # Create a repository without remote tracking
  a_real_git_repository_with_branches "${TEST_REPO}"

  cd "${TEST_REPO}"

  # Create a new branch without remote tracking
  git checkout -b feature-no-tracking
  echo "New feature" > feature.txt
  git add feature.txt
  git commit -m "Add feature"

  # Run git-push-timed
  run bash "${GIT_PUSH_TIMED_SCRIPT}"

  # Should fail with error about no remote tracking
  [ "$status" -ne 0 ]
  [[ "$output" == *"No remote tracking branch"* ]]
  [[ "$output" == *"Hint"* ]]
}

# Test displaying current and remote branch info
@test "git-push-timed displays branch information" {
  # Create a repository with remote and unpushed commits
  a_git_repository_with_unpushed_commits "${TEST_REPO}" "${TEST_REMOTE}"

  cd "${TEST_REPO}"

  # Run in dry-run mode
  run bash "${GIT_PUSH_TIMED_SCRIPT}" --dry-run
  [ "$status" -eq 0 ]

  # Should display branch names
  [[ "$output" == *"Current branch:"* ]]
  [[ "$output" == *"Remote branch:"* ]]
  [[ "$output" == *"master"* ]] || [[ "$output" == *"main"* ]]
}

# Test displaying commit information
@test "git-push-timed displays commit details" {
  # Create a repository with remote and unpushed commits
  a_git_repository_with_unpushed_commits "${TEST_REPO}" "${TEST_REMOTE}"

  cd "${TEST_REPO}"

  # Run in dry-run mode
  run bash "${GIT_PUSH_TIMED_SCRIPT}" --dry-run
  [ "$status" -eq 0 ]

  # Should display commit details
  [[ "$output" == *"Hash:"* ]]
  [[ "$output" == *"Date:"* ]]
  [[ "$output" == *"Message:"* ]]
}

# Test counting commits correctly
@test "git-push-timed counts unpushed commits correctly" {
  # Create a repository with remote
  a_git_repository_with_remote_tracking "${TEST_REPO}" "${TEST_REMOTE}"

  cd "${TEST_REPO}"

  # Create multiple unpushed commits
  for i in {1..3}; do
    echo "Feature ${i}" > "feature${i}.txt"
    git add "feature${i}.txt"
    git commit -m "Add feature ${i}"
  done

  # Run in dry-run mode
  run bash "${GIT_PUSH_TIMED_SCRIPT}" --dry-run
  [ "$status" -eq 0 ]

  # Should show correct count
  [[ "$output" == *"Found 3 commits"* ]]
  [[ "$output" == *"1/3"* ]]
  [[ "$output" == *"2/3"* ]]
  [[ "$output" == *"3/3"* ]]
}

# Test that commits are processed in chronological order
@test "git-push-timed processes commits in chronological order" {
  # Create a repository with remote and unpushed commits
  a_git_repository_with_remote_tracking "${TEST_REPO}" "${TEST_REMOTE}"

  cd "${TEST_REPO}"

  # Create commits with specific messages
  echo "First" > first.txt
  git add first.txt
  git commit -m "First commit"

  echo "Second" > second.txt
  git add second.txt
  git commit -m "Second commit"

  echo "Third" > third.txt
  git add third.txt
  git commit -m "Third commit"

  # Run in dry-run mode
  run bash "${GIT_PUSH_TIMED_SCRIPT}" --dry-run
  [ "$status" -eq 0 ]

  # Verify order in output
  # Extract line numbers for each commit message
  FIRST_LINE=$(echo "$output" | grep -n "First commit" | cut -d: -f1)
  SECOND_LINE=$(echo "$output" | grep -n "Second commit" | cut -d: -f1)
  THIRD_LINE=$(echo "$output" | grep -n "Third commit" | cut -d: -f1)

  # First should appear before Second, which should appear before Third
  [ "$FIRST_LINE" -lt "$SECOND_LINE" ]
  [ "$SECOND_LINE" -lt "$THIRD_LINE" ]
}

# Test with main branch instead of master
@test "git-push-timed works with main branch" {
  # Create a repository with main as the default branch
  a_git_repository_with_main_and_remote "${TEST_REPO}" "${TEST_REMOTE}"

  cd "${TEST_REPO}"

  # Create unpushed commits
  echo "Feature" > feature.txt
  git add feature.txt
  git commit -m "Add feature"

  # Run in dry-run mode
  run bash "${GIT_PUSH_TIMED_SCRIPT}" --dry-run
  [ "$status" -eq 0 ]

  # Should work correctly
  [[ "$output" == *"main"* ]]
  [[ "$output" == *"Found 1 commits"* ]]
}

# Test wait_until function with past timestamps
@test "git-push-timed doesn't wait for commits with past timestamps" {
  # Create a repository with remote and unpushed commits
  a_git_repository_with_unpushed_commits "${TEST_REPO}" "${TEST_REMOTE}"

  cd "${TEST_REPO}"

  # Run in dry-run mode and measure time
  START_TIME=$(date +%s)
  run bash "${GIT_PUSH_TIMED_SCRIPT}" --dry-run
  END_TIME=$(date +%s)

  # Should complete quickly (within 5 seconds)
  ELAPSED=$((END_TIME - START_TIME))
  [ "$ELAPSED" -lt 5 ]

  # Should still show the commits
  [ "$status" -eq 0 ]
  [[ "$output" == *"commits to push"* ]]
}

# Test that script preserves commit messages
@test "git-push-timed preserves commit messages in output" {
  # Create a repository with remote
  a_git_repository_with_remote_tracking "${TEST_REPO}" "${TEST_REMOTE}"

  cd "${TEST_REPO}"

  # Create commit with special characters
  echo "Content" > file.txt
  git add file.txt
  git commit -m "Fix bug #123: Handle special chars !@#$%"

  # Run in dry-run mode
  run bash "${GIT_PUSH_TIMED_SCRIPT}" --dry-run
  [ "$status" -eq 0 ]

  # Should show the exact commit message
  [[ "$output" == *"Fix bug #123: Handle special chars !@#\$%"* ]]
}

# Test with feature branch
@test "git-push-timed works on feature branches" {
  # Create a repository with remote
  a_git_repository_with_remote_tracking "${TEST_REPO}" "${TEST_REMOTE}"

  cd "${TEST_REPO}"

  # Create and push a feature branch
  git checkout -b feature/test
  echo "Feature" > feature.txt
  git add feature.txt
  git commit -m "Add feature"

  # Set up remote tracking for the branch
  cd "${TEST_REMOTE}"
  git checkout -b feature/test
  cd "${TEST_REPO}"

  git branch --set-upstream-to=origin/feature/test

  # Create another commit that's not pushed
  echo "More" > more.txt
  git add more.txt
  git commit -m "Add more"

  # Run in dry-run mode
  run bash "${GIT_PUSH_TIMED_SCRIPT}" --dry-run
  [ "$status" -eq 0 ]

  # Should show feature branch
  [[ "$output" == *"feature/test"* ]]
  [[ "$output" == *"Add more"* ]]
}

# Test output includes success message on dry-run completion
@test "git-push-timed shows completion message in dry-run" {
  # Create a repository with remote and unpushed commits
  a_git_repository_with_unpushed_commits "${TEST_REPO}" "${TEST_REMOTE}"

  cd "${TEST_REPO}"

  # Run in dry-run mode
  run bash "${GIT_PUSH_TIMED_SCRIPT}" --dry-run
  [ "$status" -eq 0 ]

  # Should show completion message
  [[ "$output" == *"Dry run complete"* ]]
  [[ "$output" == *"No commits were actually pushed"* ]]
}

# Test that timestamps are displayed
@test "git-push-timed displays commit timestamps" {
  # Create a repository with remote and unpushed commits
  a_git_repository_with_unpushed_commits "${TEST_REPO}" "${TEST_REMOTE}"

  cd "${TEST_REPO}"

  # Run in dry-run mode
  run bash "${GIT_PUSH_TIMED_SCRIPT}" --dry-run
  [ "$status" -eq 0 ]

  # Should show date in output
  [[ "$output" == *"Date:"* ]]
  # Date format should include year
  [[ "$output" =~ [0-9]{4} ]]
}

# Test handling commits with identical timestamps
@test "git-push-timed handles commits with same timestamp" {
  # Create a repository with remote
  a_git_repository_with_remote_tracking "${TEST_REPO}" "${TEST_REMOTE}"

  cd "${TEST_REPO}"

  # Create multiple commits quickly (likely same second)
  for i in {1..3}; do
    echo "File ${i}" > "file${i}.txt"
    git add "file${i}.txt"
    git commit -m "Commit ${i}"
  done

  # Run in dry-run mode
  run bash "${GIT_PUSH_TIMED_SCRIPT}" --dry-run
  [ "$status" -eq 0 ]

  # Should handle all commits
  [[ "$output" == *"Found 3 commits"* ]]
}

# Test with detached HEAD (should fail or warn)
@test "git-push-timed handles detached HEAD state" {
  # Create a repository with remote
  a_git_repository_with_remote_tracking "${TEST_REPO}" "${TEST_REMOTE}"

  cd "${TEST_REPO}"

  # Create a commit
  echo "Feature" > feature.txt
  git add feature.txt
  git commit -m "Add feature"

  # Get the commit hash
  COMMIT_HASH=$(git rev-parse HEAD)

  # Detach HEAD
  git checkout "${COMMIT_HASH}"

  # Run git-push-timed
  run bash "${GIT_PUSH_TIMED_SCRIPT}" --dry-run

  # Should fail or warn about detached HEAD
  # The current branch name will be "HEAD" in detached state
  if [ "$status" -ne 0 ]; then
    # Acceptable to fail
    [[ "$output" == *"Error"* ]] || [[ "$output" == *"HEAD"* ]]
  else
    # If it doesn't fail, it should at least show HEAD
    [[ "$output" == *"HEAD"* ]]
  fi
}
