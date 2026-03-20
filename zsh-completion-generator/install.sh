#!/bin/sh
#
# zsh-completion-generator
#
# Installs the zsh-completion-generator plugin and generates
# completions for CLI tools that don't ship their own.

set -e

PLUGIN_DIR="${HOME}/.zsh-completion-generator"

# Clone or update the plugin
if [ -d "${PLUGIN_DIR}" ]; then
  echo "Updating zsh-completion-generator plugin..."
  cd "${PLUGIN_DIR}" && git pull --quiet
else
  echo "Installing zsh-completion-generator plugin..."
  git clone --quiet https://github.com/RobSis/zsh-completion-generator.git "${PLUGIN_DIR}"
fi

# Generate completions (requires zsh for the gencomp function)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if command -v zsh >/dev/null 2>&1; then
  zsh "${SCRIPT_DIR}/generate.sh"
else
  echo "Warning: zsh not found, skipping completion generation"
fi
