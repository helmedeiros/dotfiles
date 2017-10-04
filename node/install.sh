#!/usr/bin/env bash
#
# npm
#
# This installs npm packages using npm.
function installglobal() {
	npm install -g "${@}" 2> /dev/null
}

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
fi
