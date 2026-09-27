# shellcheck shell=bash

dotfiles_compinit() {
	local dump="${ZDOTDIR:-$HOME}/.zcompdump"
	local stale_after_seconds=86400

	autoload -Uz compinit
	zmodload -F zsh/stat b:zstat
	zmodload zsh/datetime

	if [[ -f "$dump" ]] && (( $(zstat +mtime -- "$dump") > EPOCHSECONDS - stale_after_seconds )); then
		compinit -C -d "$dump"
	else
		compinit -d "$dump"
	fi
}