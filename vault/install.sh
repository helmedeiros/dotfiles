#!/usr/bin/env bash

set -e

_VAULT_DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../lib/integrity.sh
. "${_VAULT_DOTFILES_ROOT}/lib/integrity.sh"

VAULT_VERSION="${VAULT_VERSION:-2.1.1}"
VAULT_BASE_URL="${VAULT_BASE_URL:-https://releases.hashicorp.com/vault}"

VAULT_SHA256_amd64="1310ccba498a08fa9bfe09c698f54f38b6d9c2ae45bae08cf91f02bc10d295b6"
VAULT_SHA256_arm64="95d100472b726d889ee380c9335191abdf5b3e6f3108cde48f4f962bfea4f009"

release_arch() {
	if [ "$(uname -m)" = "arm64" ]; then
		echo "arm64"
	else
		echo "amd64"
	fi
}

expected_checksum_for() {
	local arch="$1"

	if [ -n "${VAULT_SHA256:-}" ]; then
		echo "$VAULT_SHA256"
	elif [ "$arch" = "arm64" ]; then
		echo "$VAULT_SHA256_arm64"
	else
		echo "$VAULT_SHA256_amd64"
	fi
}

install_directory() {
	if [ -n "${VAULT_BIN_DIR:-}" ]; then
		echo "$VAULT_BIN_DIR"
	elif [ -d "/opt/homebrew/bin" ]; then
		echo "/opt/homebrew/bin"
	else
		echo "/usr/local/bin"
	fi
}

installed_version() {
	command -v vault >/dev/null 2>&1 || return 1
	vault --version | head -n 1 | cut -d ' ' -f 2 | sed 's/v//'
}

release_url() {
	local arch="$1"
	echo "${VAULT_BASE_URL}/${VAULT_VERSION}/vault_${VAULT_VERSION}_darwin_${arch}.zip"
}

place_binary() {
	local binary="$1" destination="$2"

	if [ -w "$destination" ]; then
		mv "$binary" "$destination/vault"
	else
		sudo mv "$binary" "$destination/vault"
	fi
}

arch="$(release_arch)"
bin_dir="$(install_directory)"

if current="$(installed_version)"; then
	if [ "$current" = "$VAULT_VERSION" ]; then
		echo "Vault ${VAULT_VERSION} is already installed. Skipping installation."
		exit 0
	fi
	echo "Updating Vault from version ${current} to ${VAULT_VERSION}..."
else
	echo "Vault is not installed. Installing version ${VAULT_VERSION}..."
fi

echo "Installing Vault ${VAULT_VERSION} for macOS (${arch})..."

archive="$(download_verified \
	"$(release_url "$arch")" \
	"$(expected_checksum_for "$arch")" \
	"Vault ${VAULT_VERSION} (${arch})")" || exit 1

work="$(mktemp -d)"
trap 'rm -rf "$work" "$archive"' EXIT

unzip -q "$archive" -d "$work"

if [ ! -f "$work/vault" ]; then
	echo "Error: the verified archive did not contain a vault binary" >&2
	exit 1
fi

chmod +x "$work/vault"
place_binary "$work/vault" "$bin_dir"

echo "Vault ${VAULT_VERSION} installed to ${bin_dir}/vault."
