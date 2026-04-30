#!/usr/bin/env bats

# Require BATS version 1.5.0 or higher for run flags
bats_require_minimum_version 1.5.0

# Paths to the files being tested
ZOXIDE_PATH="${BATS_TEST_DIRNAME}/../../zoxide/path.zsh"
ZOXIDE_ALIASES="${BATS_TEST_DIRNAME}/../../zoxide/aliases.zsh"
ZSHRC="${BATS_TEST_DIRNAME}/../../zsh/zshrc.symlink"

# --- Static configuration checks ---

@test "zoxide/path.zsh exports _ZO_DOCTOR=0" {
  grep -q 'export _ZO_DOCTOR=0' "${ZOXIDE_PATH}"
}

@test "zoxide/path.zsh runs zoxide init" {
  grep -q 'eval "$(zoxide init zsh)"' "${ZOXIDE_PATH}"
}

@test "zoxide/path.zsh sets cd alias to z" {
  grep -q "alias cd='z'" "${ZOXIDE_PATH}"
}

@test "zshrc does NOT contain zoxide init (belongs in path.zsh)" {
  ! grep -q 'zoxide init' "${ZSHRC}"
}

@test "zoxide/aliases.zsh does not define cd alias (defined in path.zsh)" {
  ! grep -q "^alias cd" "${ZOXIDE_ALIASES}"
}

# --- Runtime checks (only if zoxide is installed) ---

@test "_ZO_DOCTOR is 0 after sourcing path.zsh" {
  if ! command -v zoxide &>/dev/null; then
    skip "zoxide not installed"
  fi

  run /bin/zsh -c 'source "'"${ZOXIDE_PATH}"'" && echo "${_ZO_DOCTOR}"'
  [ "$status" -eq 0 ]
  [ "$output" = "0" ]
}

@test "no warning when calling z after sourcing path.zsh" {
  if ! command -v zoxide &>/dev/null; then
    skip "zoxide not installed"
  fi

  run /bin/zsh -c '
    source "'"${ZOXIDE_PATH}"'"
    z /tmp 2>&1
  '
  [ "$status" -eq 0 ]
  [[ "$output" != *"detected a possible configuration issue"* ]]
}

@test "no warning when compinit runs AFTER zoxide init" {
  if ! command -v zoxide &>/dev/null; then
    skip "zoxide not installed"
  fi

  # Simulates Docker Desktop or other tools appending compinit to zshrc
  run /bin/zsh -c '
    source "'"${ZOXIDE_PATH}"'"
    autoload -Uz compinit
    compinit -C
    z /tmp 2>&1
  '
  [ "$status" -eq 0 ]
  [[ "$output" != *"detected a possible configuration issue"* ]]
}

@test "no warning when chpwd_functions is completely cleared after init" {
  if ! command -v zoxide &>/dev/null; then
    skip "zoxide not installed"
  fi

  # Worst case: hooks entirely wiped
  run /bin/zsh -c '
    source "'"${ZOXIDE_PATH}"'"
    chpwd_functions=()
    z /tmp 2>&1
  '
  [ "$status" -eq 0 ]
  [[ "$output" != *"detected a possible configuration issue"* ]]
}

@test "cd alias works and resolves to z after sourcing path.zsh" {
  if ! command -v zoxide &>/dev/null; then
    skip "zoxide not installed"
  fi

  run /bin/zsh -c '
    source "'"${ZOXIDE_PATH}"'"
    whence -v cd
  '
  [ "$status" -eq 0 ]
  [[ "$output" == *"alias"* ]]
}
