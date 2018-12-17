#!/usr/bin/env bash
#
# npm
#
# This installs npm packages using npm.
function installglobal() {
	npm install -g "${@}" 2> /dev/null
}

function getLatest() {
	cd "$NVM_DIR"
	git fetch --tags origin
	git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" $(git rev-list --tags --max-count=1)`
}

function installNVM() {
	local -r dot_nvm="$HOME/.nvm"

	if ! [[ -d "${dot_nvm}" || -L "${dot_nvm}" ]]
	then
		git clone https://github.com/creationix/nvm.git ~/.nvm
		getLatest
		source nvm.sh
		nvm install 11.4.0
	else
		getLatest
	fi
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
fi
