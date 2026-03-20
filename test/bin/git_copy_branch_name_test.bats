#!/usr/bin/env bats

# Path to the script being tested
GIT_COPY_BRANCH_SCRIPT="${BATS_TEST_DIRNAME}/../../bin/git-copy-branch-name"

# Load the Object Mother
load "../mothers/test_mother.sh"

setup() {
  TEST_DIR="$(mktemp -d)"
  TEST_REPO="${TEST_DIR}/test-repo"
  ORIGINAL_DIR="$(pwd)"

  # Create a mock pbcopy that is a no-op
  mkdir -p "${TEST_DIR}/bin"
  cat > "${TEST_DIR}/bin/pbcopy" <<'EOF'
#!/bin/sh
cat > /dev/null
EOF
  chmod +x "${TEST_DIR}/bin/pbcopy"
  export PATH="${TEST_DIR}/bin:${PATH}"
}

teardown() {
  cd "${ORIGINAL_DIR}"
  rm -rf "${TEST_DIR}"
}

@test "git-copy-branch-name script exists and is executable" {
  [ -f "${GIT_COPY_BRANCH_SCRIPT}" ]
  [ -x "${GIT_COPY_BRANCH_SCRIPT}" ]
}

@test "git-copy-branch-name outputs the current branch name" {
  a_real_git_repository_with_branches "${TEST_REPO}"
  cd "${TEST_REPO}"

  run bash "${GIT_COPY_BRANCH_SCRIPT}"
  [ "$status" -eq 0 ]
  [[ "$output" == *"master"* ]]
}

@test "git-copy-branch-name outputs feature branch name" {
  a_real_git_repository_with_branches "${TEST_REPO}"
  cd "${TEST_REPO}"

  git checkout -b feature/my-branch
  echo "content" > feature.txt
  git add feature.txt
  git commit -m "feature commit"

  run bash "${GIT_COPY_BRANCH_SCRIPT}"
  [ "$status" -eq 0 ]
  [[ "$output" == *"feature/my-branch"* ]]
}

@test "git-copy-branch-name outputs error outside git repo" {
  mkdir -p "${TEST_DIR}/not-a-repo"
  cd "${TEST_DIR}/not-a-repo"

  run bash "${GIT_COPY_BRANCH_SCRIPT}"
  [[ "$output" == *"fatal"* ]]
}
