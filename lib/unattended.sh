#!/usr/bin/env bash

running_unattended () {
	[ -n "${CI:-}" ] || [ -n "${GITHUB_ACTIONS:-}" ] || [ ! -t 0 ]
}
