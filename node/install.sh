#!/usr/bin/env bash
#
# npm
#
# This installs npm packages using npm.
function installglobal() {
	npm install -g "${@}" 2> /dev/null
}

function installNVM() {
	curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash	
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

	installglobal spoof
	installglobal express
	installglobal request
	installglobal mocha
	installglobal harp
	installglobal grunt-cli
	installglobal grunt
	installglobal gulp
	installglobal speed-test
	installglobal newman
	installglobal @angular/cli@latest
	installglobal spotify-cli-mac
	installglobal selenium-side-runner
fi
