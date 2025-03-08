#!/bin/sh
#
# Vault
#
# This script installs Vault from HashiCorp's website
# since it's no longer available in Homebrew due to license changes.

set -e

# Define the version to install
# You can update this when you want a newer version
VAULT_VERSION="1.13.1"
ARCH="amd64"

# Check if we're on Apple Silicon
if [ "$(uname -m)" = "arm64" ]; then
  ARCH="arm64"
fi

# Check if Vault is already installed with the correct version
if command -v vault >/dev/null 2>&1; then
  INSTALLED_VERSION=$(vault --version | head -n 1 | cut -d ' ' -f 2 | sed 's/v//')
  if [ "$INSTALLED_VERSION" = "$VAULT_VERSION" ]; then
    echo "Vault ${VAULT_VERSION} is already installed. Skipping installation."
    exit 0
  else
    echo "Updating Vault from version ${INSTALLED_VERSION} to ${VAULT_VERSION}..."
  fi
else
  echo "Vault is not installed. Installing version ${VAULT_VERSION}..."
fi

echo "Installing Vault ${VAULT_VERSION} for macOS (${ARCH})..."

# Create a temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Download Vault
echo "Downloading Vault..."
curl -fsSL "https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_darwin_${ARCH}.zip" -o vault.zip

# Unzip and install
echo "Installing Vault..."
unzip -q vault.zip
chmod +x vault

# Move to /usr/local/bin or /opt/homebrew/bin depending on architecture
if [ -d "/opt/homebrew/bin" ]; then
  # Apple Silicon path
  sudo mv vault /opt/homebrew/bin/
else
  # Intel path
  sudo mv vault /usr/local/bin/
fi

# Clean up
cd -
rm -rf "$TEMP_DIR"

# Verify installation
if command -v vault >/dev/null 2>&1; then
  echo "Vault ${VAULT_VERSION} has been installed successfully!"
  vault --version
else
  echo "Installation failed. Please check the error messages above."
  exit 1
fi 