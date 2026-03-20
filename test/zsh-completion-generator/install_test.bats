#!/usr/bin/env bats

# Path to the script being tested
INSTALL_SCRIPT="${BATS_TEST_DIRNAME}/../../zsh-completion-generator/install.sh"

# Load the Object Mother
load "../mothers/gencomp_mother.sh"

setup() {
  TEST_DIR="$(mktemp -d)"
  export HOME="${TEST_DIR}"
  mkdir -p "${TEST_DIR}/bin"

  # Save original PATH
  ORIGINAL_PATH="${PATH}"
  export PATH="${TEST_DIR}/bin:${PATH}"

  # Create a mock git
  cat > "${TEST_DIR}/bin/git" << 'GIT'
#!/bin/sh
case "$1" in
  clone)
    # Find the last argument (the destination directory)
    dest=""
    for arg in "$@"; do dest="$arg"; done
    mkdir -p "$dest"
    touch "$dest/zsh-completion-generator.plugin.zsh"
    echo "git clone $*" >> "${HOME}/git.log"
    ;;
  pull)
    echo "git pull $*" >> "${HOME}/git.log"
    ;;
esac
GIT
  chmod +x "${TEST_DIR}/bin/git"

  # Create a mock zsh that logs calls
  cat > "${TEST_DIR}/bin/zsh" << 'ZSH'
#!/bin/sh
echo "zsh $*" >> "${HOME}/zsh.log"
ZSH
  chmod +x "${TEST_DIR}/bin/zsh"

  # Create a mock brew for generate.sh
  a_mock_brew_for_gencomp "${TEST_DIR}"

  # Initialize logs
  touch "${HOME}/git.log" "${HOME}/zsh.log"
}

teardown() {
  export PATH="${ORIGINAL_PATH}"
  rm -rf "${TEST_DIR}"
}

@test "clones the plugin when not present" {
  run bash "${INSTALL_SCRIPT}"

  [ "$status" -eq 0 ]
  grep -q "git clone" "${HOME}/git.log"
  [ -d "${HOME}/.zsh-completion-generator" ]
}

@test "updates plugin when already present" {
  # Pre-create the plugin directory
  mkdir -p "${HOME}/.zsh-completion-generator"
  touch "${HOME}/.zsh-completion-generator/zsh-completion-generator.plugin.zsh"

  run bash "${INSTALL_SCRIPT}"

  [ "$status" -eq 0 ]
  grep -q "git pull" "${HOME}/git.log"
}

@test "invokes generate.sh via zsh" {
  run bash "${INSTALL_SCRIPT}"

  [ "$status" -eq 0 ]
  grep -q "zsh.*generate.sh" "${HOME}/zsh.log"
}

@test "handles missing zsh gracefully" {
  # Replace zsh mock with one that simulates "not found"
  cat > "${TEST_DIR}/bin/zsh" << 'ZSH'
#!/bin/sh
exit 127
ZSH
  chmod +x "${TEST_DIR}/bin/zsh"

  # Override command -v zsh to fail by creating a wrapper script
  cat > "${TEST_DIR}/bin/command" << 'CMD'
#!/bin/sh
exit 1
CMD
  chmod +x "${TEST_DIR}/bin/command"

  # The install script uses "command -v zsh" — we need it to fail
  # Create a modified install script that skips the zsh check
  local modified_script="${TEST_DIR}/install_no_zsh.sh"
  sed 's|command -v zsh|false|g' "${INSTALL_SCRIPT}" > "${modified_script}"
  chmod +x "${modified_script}"

  run bash "${modified_script}"

  [ "$status" -eq 0 ]
  [[ "${output}" == *"Warning: zsh not found"* ]]
}
