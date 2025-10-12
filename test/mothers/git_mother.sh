#!/bin/bash
#
# git_mother.sh
#
# Object Mother for git-related test fixtures

# Function to create a git mock with customizable behavior
git_mother_create_mock() {
  local test_dir="$1"
  local rev_parse_at="$2"
  local rev_parse_upstream="$3"
  local merge_base="$4"

  mkdir -p "${test_dir}/bin"

  cat > "${test_dir}/bin/git" <<EOF
#!/bin/bash
if [[ "\$1" == "fetch" ]]; then
  exit 0
elif [[ "\$1" == "rev-parse" && "\$2" == "@" ]]; then
  echo "${rev_parse_at}"
elif [[ "\$1" == "rev-parse" && "\$2" == "@{u}" ]]; then
  echo "${rev_parse_upstream}"
elif [[ "\$1" == "merge-base" ]]; then
  echo "${merge_base}"
elif [[ "\$1" == "rev-list" && "\$2" == "--count" ]]; then
  echo "3"
elif [[ "\$1" == "rev-list" ]]; then
  echo "commit1"
  echo "commit2"
  echo "commit3"
elif [[ "\$1" == "log" ]]; then
  echo "abc123 First commit message"
  echo "def456 Second commit message"
  echo "ghi789 Third commit message"
elif [[ "\$1" == "pull" ]]; then
  echo "Updating ${rev_parse_at}..${rev_parse_upstream}"
  echo "Fast-forward"
  echo "file1 | 2 +-"
  echo "file2 | 4 ++--"
  echo "2 files changed, 3 insertions(+), 3 deletions(-)"
elif [[ "\$1" == "init" ]]; then
  echo "Initialized empty Git repository in \$PWD/.git/"
  exit 0
elif [[ "\$1" == "status" ]]; then
  echo "On branch master"
  echo "Your branch is up to date with 'origin/master'."
  echo "nothing to commit, working tree clean"
  exit 0
else
  echo "Mock git: Unknown command: \$@" >&2
  exit 0
fi
EOF
  chmod +x "${test_dir}/bin/git"
}

# Create a git mock for the "up to date" scenario
# A repository that is up to date with remote
a_git_repository_up_to_date() {
  local test_dir="$1"
  git_mother_create_mock "$test_dir" "same-hash" "same-hash" "same-hash"
}

# Create a git mock for the "behind remote" scenario
# A repository that is behind the remote
a_git_repository_behind_remote() {
  local test_dir="$1"
  git_mother_create_mock "$test_dir" "local-hash" "remote-hash" "local-hash"
}

# Create a git mock for the "local changes" scenario
# A repository with local changes that haven't been pushed
a_git_repository_with_local_changes() {
  local test_dir="$1"
  git_mother_create_mock "$test_dir" "local-hash" "remote-hash" "remote-hash"
}

# Create a git mock for the "diverged" scenario
# A repository that has diverged from remote
a_git_repository_diverged_from_remote() {
  local test_dir="$1"
  git_mother_create_mock "$test_dir" "local-hash" "remote-hash" "base-hash"
}

# Create a real git repository with branches for testing git branch operations
# This creates an actual git repository, not a mock
a_real_git_repository_with_branches() {
  local repo_dir="$1"

  # Initialize a real git repository
  mkdir -p "${repo_dir}"
  cd "${repo_dir}"

  # Configure git for this repository (avoid using user's global config)
  git init
  git config user.name "Test User"
  git config user.email "test@example.com"
  git config init.defaultBranch master

  # Create initial commit on master
  echo "Initial content" > README.md
  git add README.md
  git commit -m "Initial commit"

  # Ensure we're on master branch (in case git used main or another name)
  git branch -M master

  cd - > /dev/null
}

# Create a branch in a git repository
create_git_branch() {
  local repo_dir="$1"
  local branch_name="$2"
  local commit_message="${3:-Add feature in ${branch_name}}"

  cd "${repo_dir}"

  # Create and checkout the branch
  git checkout -b "${branch_name}"

  # Make a commit on this branch
  # Use a safe filename (replace slashes with dashes for the file)
  local safe_filename="${branch_name//\//-}.txt"
  echo "Content for ${branch_name}" >> "${safe_filename}"
  git add "${safe_filename}"
  git commit -m "${commit_message}"

  cd - > /dev/null
}

# Merge a branch into another branch
merge_git_branch() {
  local repo_dir="$1"
  local target_branch="$2"
  local source_branch="$3"

  cd "${repo_dir}"

  # Switch to target branch and merge
  git checkout "${target_branch}"
  git merge --no-ff "${source_branch}" -m "Merge ${source_branch} into ${target_branch}"

  cd - > /dev/null
}

# Set up a repository with merged branches for testing git-delete-local-merged
a_git_repository_with_merged_branches() {
  local repo_dir="$1"

  # Create base repository
  a_real_git_repository_with_branches "${repo_dir}"

  # Create branches and merge them
  create_git_branch "${repo_dir}" "feature-1" "Add feature 1"
  create_git_branch "${repo_dir}" "feature-2" "Add feature 2"

  # Merge feature-1 into master
  merge_git_branch "${repo_dir}" "master" "feature-1"

  # Merge feature-2 into master
  merge_git_branch "${repo_dir}" "master" "feature-2"

  # Create an unmerged branch
  create_git_branch "${repo_dir}" "feature-unmerged" "Work in progress"

  # Go back to master
  cd "${repo_dir}"
  git checkout master
  cd - > /dev/null
}

# Set up a repository with only master branch
a_git_repository_with_only_master() {
  local repo_dir="$1"
  a_real_git_repository_with_branches "${repo_dir}"

  cd "${repo_dir}"
  git checkout master
  cd - > /dev/null
}

# Set up a repository with a current branch that is merged
a_git_repository_on_merged_branch() {
  local repo_dir="$1"

  a_real_git_repository_with_branches "${repo_dir}"

  # Create a feature branch
  create_git_branch "${repo_dir}" "feature-merged" "Add merged feature"

  # Merge it into master
  merge_git_branch "${repo_dir}" "master" "feature-merged"

  # Stay on the feature branch (it's merged but we're on it)
  cd "${repo_dir}"
  git checkout "feature-merged"
  cd - > /dev/null
}

# Set up a repository with main as the primary branch (not master)
a_git_repository_with_main_branch() {
  local repo_dir="$1"

  mkdir -p "${repo_dir}"
  cd "${repo_dir}"

  git init
  git config user.name "Test User"
  git config user.email "test@example.com"

  # Create initial commit on main (using -b to set initial branch name)
  echo "Initial content" > README.md
  git add README.md
  git commit -m "Initial commit"
  git branch -M main

  cd - > /dev/null
}

# Set up a repository with branches that have special characters
a_git_repository_with_special_branch_names() {
  local repo_dir="$1"

  a_real_git_repository_with_branches "${repo_dir}"

  # Create branches with various naming patterns
  create_git_branch "${repo_dir}" "bugfix/issue-123" "Fix issue 123"
  create_git_branch "${repo_dir}" "feature/user-auth" "Add user auth"

  # Merge them
  merge_git_branch "${repo_dir}" "master" "bugfix/issue-123"
  merge_git_branch "${repo_dir}" "master" "feature/user-auth"

  cd "${repo_dir}"
  git checkout master
  cd - > /dev/null
}
