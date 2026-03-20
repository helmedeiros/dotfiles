#!/bin/bash
#
# gencomp_mother.sh
#
# Object Mother for zsh-completion-generator test fixtures

# Creates a mock zsh-completion-generator plugin directory
# with a fake gencomp function that creates _<tool> files
a_zsh_completion_generator_plugin() {
  local test_dir="$1"
  local plugin_dir="${test_dir}/.zsh-completion-generator"

  mkdir -p "${plugin_dir}"

  cat > "${plugin_dir}/zsh-completion-generator.plugin.zsh" << 'PLUGIN'
#!/usr/bin/env zsh
# Mock zsh-completion-generator plugin
gencomp() {
  local tool="$1"
  local output_dir="${GENCOMPL_FPATH:-.}"
  echo "#compdef ${tool}" > "${output_dir}/_${tool}"
  echo "# generated completion for ${tool}" >> "${output_dir}/_${tool}"
}
PLUGIN
}

# Creates a mock CLI tool that responds to --help
a_tool_with_help_output() {
  local test_dir="$1"
  local tool_name="$2"

  mkdir -p "${test_dir}/bin"

  cat > "${test_dir}/bin/${tool_name}" << TOOL
#!/bin/sh
if [ "\$1" = "--help" ]; then
  echo "Usage: ${tool_name} [options]"
  echo "  -v, --version  Show version"
  echo "  -h, --help     Show help"
fi
TOOL
  chmod +x "${test_dir}/bin/${tool_name}"
}

# Creates a vendor completion file in a mock fpath directory
a_tool_with_existing_vendor_completion() {
  local test_dir="$1"
  local tool_name="$2"
  local vendor_dir="${test_dir}/vendor-completions"

  mkdir -p "${vendor_dir}"
  echo "#compdef ${tool_name}" > "${vendor_dir}/_${tool_name}"
}

# Creates a pre-existing generated completion file in the output directory
a_tool_already_generated() {
  local output_dir="$1"
  local tool_name="$2"

  mkdir -p "${output_dir}"
  echo "#compdef ${tool_name}" > "${output_dir}/_${tool_name}"
}

# Creates a mock gencomp that fails for a specific tool
a_failing_gencomp_plugin() {
  local test_dir="$1"
  local failing_tool="$2"
  local plugin_dir="${test_dir}/.zsh-completion-generator"

  mkdir -p "${plugin_dir}"

  cat > "${plugin_dir}/zsh-completion-generator.plugin.zsh" << PLUGIN
#!/usr/bin/env zsh
# Mock zsh-completion-generator plugin that fails for ${failing_tool}
gencomp() {
  local tool="\$1"
  local output_dir="\${GENCOMPL_FPATH:-.}"
  if [ "\$tool" = "${failing_tool}" ]; then
    return 1
  fi
  echo "#compdef \${tool}" > "\${output_dir}/_\${tool}"
  echo "# generated completion for \${tool}" >> "\${output_dir}/_\${tool}"
}
PLUGIN
}

# Creates a mock brew command that returns a prefix
a_mock_brew_for_gencomp() {
  local test_dir="$1"
  local brew_prefix="${test_dir}/brew-prefix"

  mkdir -p "${test_dir}/bin"
  mkdir -p "${brew_prefix}/share/zsh/site-functions"
  mkdir -p "${brew_prefix}/share/zsh-completions"

  cat > "${test_dir}/bin/brew" << BREW
#!/bin/sh
if [ "\$1" = "--prefix" ]; then
  echo "${brew_prefix}"
fi
BREW
  chmod +x "${test_dir}/bin/brew"
}
