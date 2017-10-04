#!/usr/bin/env bash

function installglobal() {
	npm install -g "${@}" 2> /dev/null
}

installglobal spoof
