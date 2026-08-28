#!/usr/bin/env bash
#
# SDKMAN
#
# Installs SDKMAN and the JVM toolchain candidates that this dotfiles
# repo previously pulled from Homebrew (java/gradle/maven/groovy). SDKMAN
# owns version switching from here on — see sdkman/aliases.zsh for the
# java8/11/17/21 wrappers and sdkman/README.md for day-to-day usage.

set -eo pipefail

_SDKMAN_DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../lib/integrity.sh
. "${_SDKMAN_DOTFILES_ROOT}/lib/integrity.sh"

# Pinned SDKMAN bootstrap installer. The URL is the canonical entry point
# (it self-detects the latest CLI release at runtime); the SHA pins the
# bootstrap script itself so a hijacked redirector cannot ship arbitrary
# code into a fresh-machine install.
#
# To rotate: re-fetch the script, recompute, bump both lines together.
#   curl -fsSL "$SDKMAN_INSTALLER_URL" | shasum -a 256
SDKMAN_INSTALLER_URL="https://get.sdkman.io/?rcupdate=false"
SDKMAN_INSTALLER_SHA256="8642db91ce900cf406d2cd457c2b3c7b8fe3e4a8fe454192ae6a34df435052ec"

# Candidates installed on a fresh machine. Versions default to whatever
# SDKMAN currently considers stable — that's the whole point of moving
# off pinned Homebrew formulae and stale /usr/libexec/java_home aliases.
# Pin per-project with `.sdkmanrc` instead of here.
SDKMAN_JAVA_DEFAULT="21-tem"   # Temurin LTS

function installSDKMAN() {
	if [ -d "$HOME/.sdkman" ]; then
		echo "SDKMAN already installed at ~/.sdkman, skipping bootstrap."
		return 0
	fi

	echo "Installing SDKMAN..."

	local installer
	installer=$(download_verified \
		"${SDKMAN_INSTALLER_URL}" \
		"${SDKMAN_INSTALLER_SHA256}" \
		"SDKMAN bootstrap installer") || return 1
	trap 'rm -f "$installer"' RETURN

	# rcupdate=false (in URL) keeps SDKMAN from rewriting ~/.zshrc.
	# Shell init is owned by sdkman/path.zsh.
	bash "$installer"
}

function loadSDKMAN() {
	export SDKMAN_DIR="$HOME/.sdkman"
	# shellcheck source=/dev/null
	if [ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]; then
		# nounset stays off: SDKMAN's own `sdk` function isn't nounset-safe,
		# and every call below (sdkInstall, sdk list/current/install) goes
		# through it, not just this sourcing step.
		set +u
		. "${SDKMAN_DIR}/bin/sdkman-init.sh"
	else
		echo "Error: sdkman-init.sh missing after install" >&2
		return 1
	fi
}

# Answers "n" to SDKMAN's "set as default?" prompt without changing the
# current default. `yes n | sdk install ...` looks equivalent but is not: with
# pipefail on, `yes` is killed by SIGPIPE the moment sdk stops reading, the
# pipeline reports 141, and a perfectly good install was announced as
# "Warning: failed to install". A finite writer cannot be killed that way.
function sdkInstallQuietly() {
	printf 'n\nn\nn\n' | sdk install "$@" >/dev/null
}

function sdkInstall() {
	local candidate="$1"
	local version="${2:-}"

	if [ -n "$version" ]; then
		# Presence on disk, not `sdk current`: a candidate can be installed
		# without being the default (java 21 alongside a default java 8), and
		# asking `sdk current` re-ran the install — and the download — on every
		# single dotfiles run, under a log line claiming it was installing.
		if [ -d "${SDKMAN_DIR}/candidates/${candidate}/${version}" ]; then
			echo "$candidate $version already installed, skipping."
			return 0
		fi
		echo "Installing $candidate $version..."
		sdkInstallQuietly "$candidate" "$version" || {
			echo "Warning: failed to install $candidate $version" >&2
			return 0
		}
	else
		if sdk current "$candidate" >/dev/null 2>&1; then
			echo "$candidate already installed, skipping."
			return 0
		fi
		echo "Installing $candidate (latest stable)..."
		sdkInstallQuietly "$candidate" || {
			echo "Warning: failed to install $candidate" >&2
			return 0
		}
	fi
}

function enableGradleDaemon() {
	# Keep the daemon warm between invocations. Was previously in
	# gradle/install.sh; moved here so the whole JVM stack lives in one
	# topic.
	mkdir -p "$HOME/.gradle"
	local props="$HOME/.gradle/gradle.properties"
	touch "$props"
	if ! grep -q '^org.gradle.daemon=true$' "$props"; then
		echo "Enabling Gradle daemon."
		echo "org.gradle.daemon=true" >> "$props"
	fi
}

# --- run ---

installSDKMAN || {
	echo "Error: SDKMAN installation failed" >&2
	exit 1
}

loadSDKMAN || exit 1

sdkInstall java "${SDKMAN_JAVA_DEFAULT}"
sdkInstall gradle
sdkInstall maven
sdkInstall groovy

enableGradleDaemon

echo "SDKMAN setup complete. Try: sdk current"
