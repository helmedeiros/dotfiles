#!/usr/bin/env bash
#
# npm
#
# This installs npm packages using npm.
function installglobal() {
	echo "  Installing $*"
	npm install -g --no-fund "${@}" 2>/dev/null || echo "  Failed to install $*"
}

function installNVM() {
	echo "  Installing NVM..."
	# Check if NVM directory exists
	if [ ! -d "$HOME/.nvm" ]; then
		mkdir -p "$HOME/.nvm"
	fi
	
	# Install NVM
	curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
	
	# Source NVM immediately without auto-use
	export NVM_DIR="$HOME/.nvm"
	export NVM_AUTO_USE=false
	[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" --no-use
	
	# Verify NVM installation
	if command -v nvm &> /dev/null; then
		echo "  NVM installed successfully"
		
		# Install latest LTS version of Node.js
		nvm install --lts
		nvm use --lts
		
		echo "  Node.js $(node -v) installed"
	else
		echo "  NVM installation failed"
	fi
}

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
	echo " Node.js not found. Installing NVM and Node.js..."
	installNVM
fi

# Check for npm
if command -v npm &> /dev/null; then
  echo "  Installing npm packages for you."

  # First, remove any deprecated packages that might be installed
  echo "  Removing deprecated packages if they exist..."
  npm uninstall -g request superagent cross-spawn-async formidable 2>/dev/null || true

	# Modern networking tools
	installglobal spoof
	
	# Modern web development frameworks
	installglobal express
	installglobal axios # Modern alternative to request
	installglobal got # Modern alternative to superagent
	
	# Testing frameworks
	installglobal mocha
	
	# Build tools
	installglobal grunt-cli
	installglobal grunt
	installglobal gulp
	
	# Utility tools
	installglobal speed-test
	installglobal postman-cli # Modern alternative to newman
	installglobal cross-spawn # Modern alternative to cross-spawn-async
	installglobal uuid@latest # Modern version of uuid
	installglobal glob@latest # Modern version of glob
	
	# Media tools
	installglobal spotify-cli-mac
	
	# Testing tools
	installglobal selenium-side-runner
	
	# Development tools
	installglobal typescript
	installglobal eslint
	installglobal prettier
	
	echo "  Global npm packages have been installed/updated!"
	echo "  Some warnings may still appear for packages that depend on deprecated packages."
else
	echo "  npm not found even after Node.js installation. Something went wrong."
fi
