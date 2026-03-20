#!/usr/bin/env bats

# Path to the script being tested
GIT_UNPUSHED_STAT_SCRIPT="${BATS_TEST_DIRNAME}/../../bin/git-unpushed-stat"

# Load the Object Mother
load "../mothers/test_mother.sh"

setup() {
  TEST_DIR="$(mktemp -d)"
  TEST_REPO="${TEST_DIR}/test-repo"
  TEST_REMOTE="${TEST_DIR}/test-remote"
  ORIGINAL_DIR="$(pwd)"

  # Create a mock difftool that outputs stat-like format
  mkdir -p "${TEST_DIR}/mock-bin"
  cat > "${TEST_DIR}/mock-bin/git" <<'MOCKEOF'
#!/bin/bash
# Pass through to real git, but intercept difftool
if [[ "$1" == "difftool" ]]; then
  # Use real git diff --stat instead
  shift
  # Replace difftool with diff
  exec /usr/bin/git diff "${@}"
else
  exec /usr/bin/git "$@"
fi
MOCKEOF
  chmod +x "${TEST_DIR}/mock-bin/git"
}

teardown() {
  cd "${ORIGINAL_DIR}"
  rm -rf "${TEST_DIR}"
}

@test "git-unpushed-stat script exists and is executable" {
  [ -f "${GIT_UNPUSHED_STAT_SCRIPT}" ]
  [ -x "${GIT_UNPUSHED_STAT_SCRIPT}" ]
}

@test "git-unpushed-stat shows commit count with singular form" {
  a_git_repository_with_remote_tracking "${TEST_REPO}" "${TEST_REMOTE}"
  cd "${TEST_REPO}"

  # Create exactly 1 unpushed commit
  echo "feature" > feature.txt
  git add feature.txt
  git commit -m "Add feature"

  # Use mock git to avoid interactive difftool
  export PATH="${TEST_DIR}/mock-bin:${PATH}"

  run bash "${GIT_UNPUSHED_STAT_SCRIPT}"
  [ "$status" -eq 0 ]
  [[ "$output" == *"1 commit total"* ]]
}

@test "git-unpushed-stat shows commit count with plural form" {
  a_git_repository_with_remote_tracking "${TEST_REPO}" "${TEST_REMOTE}"
  cd "${TEST_REPO}"

  # Create multiple unpushed commits
  for i in 1 2 3; do
    echo "feature ${i}" > "feature${i}.txt"
    git add "feature${i}.txt"
    git commit -m "Add feature ${i}"
  done

  export PATH="${TEST_DIR}/mock-bin:${PATH}"

  run bash "${GIT_UNPUSHED_STAT_SCRIPT}"
  [ "$status" -eq 0 ]
  [[ "$output" == *"3 commits total"* ]]
}
