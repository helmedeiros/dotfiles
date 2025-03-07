#!/usr/bin/env bash
#
# npm
#
# This installs npm packages using npm.
function installglobal() {
	npm install -g --no-fund "${@}" 2> /dev/null
}

function installNVM() {
	curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash	
}

if test $(which node)
then
	echo " Installing npm manually"
	installNVM
fi

# Check for npm
if test $(which npm)
then
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
	
	# Framework CLIs
	installglobal @angular/cli@latest
	
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
fi
