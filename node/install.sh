#!/usr/bin/env bash
#
# npm
#
# This installs modern npm packages using npm.

set -eo pipefail

_NODE_DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../lib/integrity.sh
. "${_NODE_DOTFILES_ROOT}/lib/integrity.sh"

function installglobal() {
	echo "Installing $*..."
	if npm install -g --no-fund "${@}" 2>/dev/null; then
		echo "✅ Successfully installed $*"
	else
		echo "❌ Error: Failed to install $*, continuing with other packages..."
		# Don't exit, just continue with other packages
	fi
}

# Pinned nvm release. Bump both fields together — the SHA must match the
# install.sh that ships in the named tag.
NVM_VERSION="v0.39.7"
NVM_INSTALLER_SHA256="8e45fa547f428e9196a5613efad3bfa4d4608b74ca870f930090598f5af5f643"

# Pinned Node.js release, shared with bin/dot via node/.nvmrc so both land on
# the same runtime. Frozen on purpose rather than tracking --lts; bump the file
# to move it, and keep it new enough for npm@latest's engines field.
NODE_VERSION="$(cat "${_NODE_DOTFILES_ROOT}/node/.nvmrc" 2>/dev/null || echo "--lts")"

function installNVM() {
	# Check if NVM directory exists
	if [ ! -d "$HOME/.nvm" ]; then
		mkdir -p "$HOME/.nvm"
	fi

	# Install NVM. Download the installer to a tempfile, verify the SHA-256
	# against the pinned value, then execute. The previous 'curl | bash'
	# pattern had no integrity check — a compromised CDN or upstream tag
	# could have shipped arbitrary code straight into the user's shell.
	echo "Installing NVM ${NVM_VERSION}..."

	local installer
	installer=$(download_verified \
		"https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" \
		"$NVM_INSTALLER_SHA256" \
		"NVM ${NVM_VERSION} installer") || return 1
	trap 'rm -f "$installer"' RETURN

	bash "$installer"

	# Source NVM immediately without auto-use
	export NVM_DIR="$HOME/.nvm"
	export NVM_AUTO_USE=false
	[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" --no-use

	# Verify NVM installation
	if command -v nvm &> /dev/null; then
		# Install the pinned Node.js version
		echo "Installing Node.js ${NODE_VERSION}..."
		nvm install "${NODE_VERSION}"
		nvm use "${NODE_VERSION}"
	else
		echo "Error: NVM installation failed"
		return 1
	fi
}

# Always ensure nvm is available, even when Homebrew already provides a
# system-wide node — engineers routinely need per-project Node versions
# via nvm/.nvmrc alongside that default, not only as a fallback.
export NVM_DIR="$HOME/.nvm"
if [ ! -s "$NVM_DIR/nvm.sh" ]; then
	installNVM || echo "Error: NVM installation failed"
else
	export NVM_AUTO_USE=false
	\. "$NVM_DIR/nvm.sh" --no-use
	nvm use "${NODE_VERSION}" &> /dev/null || true
fi

# Check for npm
if command -v npm &> /dev/null; then
  echo "Installing npm packages..."

  # First, remove any deprecated packages that might be installed
  npm uninstall -g request superagent cross-spawn-async formidable grunt grunt-cli 2>/dev/null || true

	# Modern networking tools
	installglobal axios # Modern HTTP client
	installglobal got # Alternative HTTP client with better API

	# Modern build tools (replacing grunt/gulp)
	installglobal vite # Modern build tool
	installglobal esbuild # Fast JavaScript bundler
	installglobal rollup # Module bundler

	# Package management and utilities
	installglobal npm-check-updates # Check for outdated packages
	installglobal npm-check # Interactive update utility
	# Note: npx comes bundled with npm (since npm 5.2.0), no separate installation needed

	# Development tools
	installglobal typescript
	installglobal eslint
	installglobal prettier
	installglobal nodemon # Auto-restart for development

	# Testing frameworks
	installglobal vitest # Modern test runner
	installglobal jest # Popular testing framework

	# Utility tools
	installglobal cross-spawn # Modern alternative to cross-spawn-async
	installglobal uuid@latest # UUID generation
	installglobal glob@latest # File pattern matching
	installglobal rimraf # Cross-platform rm -rf

	# Modern CLI tools
	installglobal serve # Static file server
	installglobal http-server # Simple HTTP server
	installglobal live-server # Development server with live reload

	# Media and system tools
	installglobal spotify-cli-mac
	installglobal speed-test

	# Optional: Keep gulp for legacy projects (commented out by default)
	# installglobal gulp
	# installglobal gulp-cli

	echo "npm packages installation completed"
else
	echo "Error: npm not found even after Node.js installation. Something went wrong."
fi
