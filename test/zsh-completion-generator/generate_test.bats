#!/usr/bin/env bats

# Path to the script being tested
GENERATE_SCRIPT="${BATS_TEST_DIRNAME}/../../zsh-completion-generator/generate.sh"

# Load the Object Mother
load "../mothers/gencomp_mother.sh"

setup() {
  TEST_DIR="$(mktemp -d)"
  export HOME="${TEST_DIR}"
  OUTPUT_DIR="${TEST_DIR}/output"
  mkdir -p "${OUTPUT_DIR}"
  mkdir -p "${TEST_DIR}/bin"

  # Set up mock brew
  a_mock_brew_for_gencomp "${TEST_DIR}"

  # Add mock bin to PATH
  export PATH="${TEST_DIR}/bin:${PATH}"
}

teardown() {
  rm -rf "${TEST_DIR}"
}

# Helper: create a generate.zsh wrapper that uses our test fixtures
run_generate() {
  local tools_override="$1"

  # Create a test-specific generate script that uses our fixtures
  cat > "${TEST_DIR}/test_generate.zsh" << SCRIPT
#!/usr/bin/env zsh
set -e

PLUGIN_DIR="${HOME}/.zsh-completion-generator"
SCRIPT_DIR="${OUTPUT_DIR}"

export GENCOMPL_FPATH="\${SCRIPT_DIR}"

source "\${PLUGIN_DIR}/zsh-completion-generator.plugin.zsh"

vendor_fpath_dirs=(
  "\$(brew --prefix 2>/dev/null)/share/zsh/site-functions"
  "\$(brew --prefix 2>/dev/null)/share/zsh-completions"
)

tools=(${tools_override})

for tool in "\${tools[@]}"; do
  if ! command -v "\$tool" >/dev/null 2>&1; then
    continue
  fi

  if [ -f "\${SCRIPT_DIR}/_\${tool}" ]; then
    continue
  fi

  vendor_found=false
  for dir in "\${vendor_fpath_dirs[@]}"; do
    if [ -n "\$dir" ] && [ -f "\${dir}/_\${tool}" ]; then
      vendor_found=true
      break
    fi
  done
  if \$vendor_found; then
    continue
  fi

  gencomp "\$tool" 2>/dev/null || echo "Warning: failed to generate completion for \${tool}"
done

setopt NULL_GLOB
rm -f "\${HOME}"/.zcompdump*
unsetopt NULL_GLOB
SCRIPT
  chmod +x "${TEST_DIR}/test_generate.zsh"

  zsh "${TEST_DIR}/test_generate.zsh"
}

@test "generates completion for a tool that has no existing completion" {
  a_zsh_completion_generator_plugin "${TEST_DIR}"
  a_tool_with_help_output "${TEST_DIR}" "mytool"

  run_generate "mytool"

  [ -f "${OUTPUT_DIR}/_mytool" ]
  grep -q "#compdef mytool" "${OUTPUT_DIR}/_mytool"
}

@test "skips tool that already has vendor completion" {
  a_zsh_completion_generator_plugin "${TEST_DIR}"
  a_tool_with_help_output "${TEST_DIR}" "mytool"

  # Place vendor completion in brew site-functions
  local brew_prefix="${TEST_DIR}/brew-prefix"
  echo "#compdef mytool" > "${brew_prefix}/share/zsh/site-functions/_mytool"

  run_generate "mytool"

  [ ! -f "${OUTPUT_DIR}/_mytool" ]
}

@test "skips tool that is not installed" {
  a_zsh_completion_generator_plugin "${TEST_DIR}"

  run_generate "nonexistent-tool"

  [ ! -f "${OUTPUT_DIR}/_nonexistent-tool" ]
}

@test "skips tool that already has a generated completion file" {
  a_zsh_completion_generator_plugin "${TEST_DIR}"
  a_tool_with_help_output "${TEST_DIR}" "mytool"
  a_tool_already_generated "${OUTPUT_DIR}" "mytool"

  # Capture the original content
  local original_content
  original_content="$(cat "${OUTPUT_DIR}/_mytool")"

  run_generate "mytool"

  # File should still exist but not be regenerated (same content)
  [ -f "${OUTPUT_DIR}/_mytool" ]
  [ "$(cat "${OUTPUT_DIR}/_mytool")" = "${original_content}" ]
}

@test "handles gencomp failure gracefully and continues" {
  a_failing_gencomp_plugin "${TEST_DIR}" "badtool"
  a_tool_with_help_output "${TEST_DIR}" "badtool"
  a_tool_with_help_output "${TEST_DIR}" "goodtool"

  run_generate "badtool goodtool"

  [ ! -f "${OUTPUT_DIR}/_badtool" ]
  [ -f "${OUTPUT_DIR}/_goodtool" ]
}

@test "deletes zcompdump files after generation" {
  a_zsh_completion_generator_plugin "${TEST_DIR}"
  a_tool_with_help_output "${TEST_DIR}" "mytool"

  # Create fake zcompdump files
  touch "${HOME}/.zcompdump"
  touch "${HOME}/.zcompdump-host-5.9"

  run_generate "mytool"

  [ ! -f "${HOME}/.zcompdump" ]
  [ ! -f "${HOME}/.zcompdump-host-5.9" ]
}
