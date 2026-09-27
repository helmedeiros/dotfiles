#!/bin/sh

set -e

ZSH_BIN="${ZSH_BIN-$(command -v zsh 2>/dev/null || true)}"
SHELLS_FILE="${SHELLS_FILE:-/etc/shells}"

homebrew_completion_dir() {
	command -v brew >/dev/null 2>&1 || return 1

	prefix="$(brew --prefix 2>/dev/null || true)"
	[ -n "$prefix" ] || return 1
	[ -d "$prefix/share/zsh" ] || return 1

	echo "$prefix/share/zsh"
}

has_world_or_group_write() {
	[ -n "$(find "$1" \( -perm -g+w -o -perm -o+w \) -print -quit 2>/dev/null)" ]
}

tighten_completion_permissions() {
	completion_dir="$(homebrew_completion_dir)" || return 0
	has_world_or_group_write "$completion_dir" || return 0

	echo "  Tightening permissions on $completion_dir so compinit will load it."
	sudo chmod -R go-w "$completion_dir"
}

login_shell_is_zsh() {
	case "$SHELL" in
		*/zsh) return 0 ;;
		*) return 1 ;;
	esac
}

listed_zsh() {
	if grep -qxF "$ZSH_BIN" "$SHELLS_FILE" 2>/dev/null; then
		echo "$ZSH_BIN"
	elif grep -qxF /bin/zsh "$SHELLS_FILE" 2>/dev/null; then
		echo "/bin/zsh"
	fi
}

adopt_zsh_as_login_shell() {
	login_shell_is_zsh && return 0

	target="$(listed_zsh)"
	if [ -z "$target" ]; then
		echo "  No zsh is listed in $SHELLS_FILE, leaving the login shell alone."
		echo "  Add $ZSH_BIN to $SHELLS_FILE first, then re-run this."
		return 0
	fi

	echo "  Making $target your login shell."
	chsh -s "$target"
}

if [ -z "$ZSH_BIN" ]; then
	echo "  zsh is not installed, skipping."
	echo "  It ships in the Brewfile — 'brew install zsh' — then re-run this."
	exit 0
fi

tighten_completion_permissions
adopt_zsh_as_login_shell
