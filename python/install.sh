#!/usr/bin/env bash
#
# python
#
# This sets up pyenv and Python environments.

set -eo pipefail

# Check if pyenv is installed, install if missing
if ! command -v pyenv &> /dev/null; then
  echo "⚠️  pyenv not found. Installing via Homebrew..."
  if command -v brew &> /dev/null; then
    brew install pyenv
  else
    echo "❌ Homebrew not found. Please install pyenv manually."
    exit 1
  fi
fi

echo "🐍 Setting up Python environment..."

# Initialize pyenv for this script
export PYENV_ROOT="$HOME/.pyenv"
eval "$(pyenv init -)"

# Function to install Python version if not already installed
function install_python_version() {
  local version=$1
  echo "Checking Python $version..."

  if pyenv versions --bare | grep -q "^${version}$"; then
    echo "✅ Python $version is already installed"
  else
    echo "📦 Installing Python $version..."
    if pyenv install -s "$version"; then
      echo "✅ Successfully installed Python $version"
    else
      echo "❌ Failed to install Python $version"
      return 1
    fi
  fi
}

# Install commonly needed Python versions
# Python 3.8 - for legacy apps (like goDebug) that require older Python
install_python_version "3.8.20" || true

# Python 3.11 - stable LTS version
install_python_version "3.11.11" || true

# Python 3.12 - recent stable version
install_python_version "3.12.8" || true

# Set global Python version to 3.12 if not already set
current_global=$(pyenv global 2>/dev/null || echo "system")
if [ "$current_global" = "system" ]; then
  if pyenv versions --bare | grep -q "^3.12"; then
    echo "Setting global Python to 3.12..."
    pyenv global 3.12.8
  fi
fi

echo ""
echo "Python installation complete!"
echo ""
echo "💡 Tips:"
echo "  - Use 'pyenv versions' to see installed Python versions"
echo "  - Use 'pyenv global X.Y.Z' to set the global Python version"
echo "  - Use 'pyenv local X.Y.Z' in a project directory to set project-specific version"
echo "  - Create a .python-version file in a project to automatically use that version"
echo ""
