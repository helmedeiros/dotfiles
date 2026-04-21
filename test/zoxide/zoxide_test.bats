#!/usr/bin/env bats

# Require BATS version 1.5.0 or higher for run flags
bats_require_minimum_version 1.5.0

# Paths to the files being tested
ZOXIDE_PATH="${BATS_TEST_DIRNAME}/../../zoxide/path.zsh"
ZSHRC="${BATS_TEST_DIRNAME}/../../zsh/zshrc.symlink"

# --- Static configuration checks ---

@test "zoxide/path.zsh exports _ZO_DOCTOR=0" {
  grep -q 'export _ZO_DOCTOR=0' "${ZOXIDE_PATH}"
}

@test "zoxide/path.zsh sets cd alias to z" {
  grep -q "alias cd='z'" "${ZOXIDE_PATH}"
}

@test "zoxide/path.zsh guards on interactive shell" {
  grep -q '\[\[ -o interactive \]\]' "${ZOXIDE_PATH}"
}

@test "zshrc initializes zoxide at the very end" {
  local init_line
  init_line=$(grep -n 'zoxide init zsh' "${ZSHRC}" | tail -1 | cut -d: -f1)
  [ -n "${init_line}" ]

  local total_lines
  total_lines=$(wc -l < "${ZSHRC}" | tr -d ' ')

  # zoxide init block (with its closing fi) must be within the last 5 lines
  local distance=$(( total_lines - init_line ))
  [ "${distance}" -le 4 ]
}

@test "zshrc guards zoxide init on interactive shell" {
  grep -q 'zoxide.*interactive' "${ZSHRC}"
}

@test "zoxide path.zsh is sourced before zoxide init in zshrc" {
  local path_loop_line
  path_loop_line=$(grep -n 'for file in.*path.zsh' "${ZSHRC}" | head -1 | cut -d: -f1)

  local init_line
  init_line=$(grep -n 'zoxide init zsh' "${ZSHRC}" | tail -1 | cut -d: -f1)

  [ "${path_loop_line}" -lt "${init_line}" ]
}

# --- Runtime checks (only if zoxide is installed) ---

@test "no zoxide warning on stderr when sourcing path.zsh" {
  if ! command -v zoxide &>/dev/null; then
    skip "zoxide not installed"
  fi

  local stderr
  stderr=$(bash -c 'source "'"${ZOXIDE_PATH}"'"' 2>&1 >/dev/null)

  [[ "${stderr}" != *"detected a possible configuration issue"* ]]
}

@test "_ZO_DOCTOR is 0 after sourcing path.zsh in interactive zsh" {
  if ! command -v zoxide &>/dev/null; then
    skip "zoxide not installed"
  fi

  run /bin/zsh -i -c 'source "'"${ZOXIDE_PATH}"'" && echo "${_ZO_DOCTOR}"'
  [ "$status" -eq 0 ]
  [[ "$output" == *"0"* ]]
}

@test "no zoxide warning when calling z after full init" {
  if ! command -v zoxide &>/dev/null; then
    skip "zoxide not installed"
  fi

  local stderr
  stderr=$(/bin/zsh -i -c '
    source "'"${ZOXIDE_PATH}"'"
    eval "$(zoxide init zsh)"
    z /tmp 2>&1 >/dev/null
  ' 2>&1)

  [[ "${stderr}" != *"detected a possible configuration issue"* ]]
}

@test "non-interactive shell does not load zoxide alias or init" {
  if ! command -v zoxide &>/dev/null; then
    skip "zoxide not installed"
  fi

  # In non-interactive zsh, the interactive guard should skip zoxide setup
  local output
  output=$(/bin/zsh -c '
    source "'"${ZOXIDE_PATH}"'"
    alias cd 2>&1 || echo "no-alias"
  ' 2>&1)

  [[ "${output}" == *"no-alias"* ]] || [[ "${output}" != *"cd=z"* ]]
}

@test "no zoxide warning when cd is used in non-interactive shell" {
  if ! command -v zoxide &>/dev/null; then
    skip "zoxide not installed"
  fi

  local stderr
  stderr=$(/bin/zsh -c '
    source "'"${ZOXIDE_PATH}"'"
    eval "$(zoxide init zsh 2>/dev/null)" 2>/dev/null
    cd /tmp 2>&1
  ' 2>&1)

  [[ "${stderr}" != *"detected a possible configuration issue"* ]]
}
