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

	# Modern networking tools
	installglobal spoof
	
	# Modern web development frameworks
	installglobal express
	installglobal axios # Modern alternative to request
	
	# Testing frameworks
	installglobal mocha
	
	# Build tools
	installglobal grunt-cli
	installglobal grunt
	installglobal gulp
	
	# Utility tools
	installglobal speed-test
	installglobal postman-cli # Modern alternative to newman
	
	# Framework CLIs
	installglobal @angular/cli@latest
	
	# Media tools
	installglobal spotify-cli-mac
	
	# Testing tools
	installglobal selenium-side-runner
fi
