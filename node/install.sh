#!/usr/bin/env bash
#
# npm
#
# This installs modern npm packages using npm.

set -eo pipefail

function installglobal() {
	echo "Installing $*..."
	if npm install -g --no-fund "${@}" 2>/dev/null; then
		echo "✅ Successfully installed $*"
	else
		echo "❌ Error: Failed to install $*, continuing with other packages..."
		# Don't exit, just continue with other packages
	fi
}

function installNVM() {
	# Check if NVM directory exists
	if [ ! -d "$HOME/.nvm" ]; then
		mkdir -p "$HOME/.nvm"
	fi

	# Install NVM
	echo "Installing NVM..."
	curl -s -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

	# Source NVM immediately without auto-use
	export NVM_DIR="$HOME/.nvm"
	export NVM_AUTO_USE=false
	[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" --no-use

	# Verify NVM installation
	if command -v nvm &> /dev/null; then
		# Install latest LTS version of Node.js
		echo "Installing Node.js..."
		nvm install --lts
		nvm use --lts
	else
		echo "Error: NVM installation failed"
		return 1
	fi
}

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
	installNVM || echo "Error: Node.js installation failed"
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
