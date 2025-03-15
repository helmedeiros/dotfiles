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
