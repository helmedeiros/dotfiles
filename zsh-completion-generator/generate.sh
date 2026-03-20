#!/usr/bin/env zsh
#
# generate.zsh
#
# Generates zsh completions for CLI tools using zsh-completion-generator.
# Called by install.sh — not sourced at shell startup.

PLUGIN_DIR="${HOME}/.zsh-completion-generator"
SCRIPT_DIR="${0:a:h}"

# Output generated completions into this topic directory
export GENCOMPL_FPATH="${SCRIPT_DIR}"

# Source the plugin to get the gencomp function
if [ ! -f "${PLUGIN_DIR}/zsh-completion-generator.plugin.zsh" ]; then
  echo "Error: zsh-completion-generator plugin not found at ${PLUGIN_DIR}"
  exit 1
fi
source "${PLUGIN_DIR}/zsh-completion-generator.plugin.zsh"

# Directories where vendor/brew completions may already exist
vendor_fpath_dirs=(
  "$(brew --prefix 2>/dev/null)/share/zsh/site-functions"
  "$(brew --prefix 2>/dev/null)/share/zsh-completions"
  "/usr/share/zsh/site-functions"
  "/usr/local/share/zsh/site-functions"
)

# CLI tools to generate completions for
tools=(
  spotify speed-test http-server live-server serve nodemon
  prettier eslint rimraf npm-check npm-check-updates
  vite esbuild rollup vitest
)

for tool in "${tools[@]}"; do
  # Skip if not installed
  if ! command -v "$tool" >/dev/null 2>&1; then
    continue
  fi

  # Skip if already generated in this topic dir
  if [ -f "${SCRIPT_DIR}/_${tool}" ]; then
    continue
  fi

  # Skip if vendor completion exists
  vendor_found=false
  for dir in "${vendor_fpath_dirs[@]}"; do
    if [ -n "$dir" ] && [ -f "${dir}/_${tool}" ]; then
      vendor_found=true
      break
    fi
  done
  if $vendor_found; then
    continue
  fi

  # Generate completion (continue on failure)
  echo "Generating completion for ${tool}..."
  gencomp "$tool" 2>/dev/null || echo "Warning: failed to generate completion for ${tool}"
done

# Force compinit rebuild on next shell startup
setopt NULL_GLOB
rm -f "${HOME}"/.zcompdump*
unsetopt NULL_GLOB

echo "Completion generation finished."
