#!/bin/bash
#
# Kubernetes Configuration Setup
#
# This script sets up kubectl configuration using company-specific settings from .dot-secrets

set -e

# Define paths
DOT_SECRETS_DIR="$HOME/.dot-secrets"
KUBE_CONFIG_DIR="$DOT_SECRETS_DIR/kubernetes"
KUBE_CONFIG_FILE="$KUBE_CONFIG_DIR/config.sh"
TEMPLATE_DIR="$HOME/.dotfiles/templates/dot-secrets/kubernetes"

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
  echo "Error: kubectl is not installed"
  echo "Please install kubectl first: brew install kubernetes-cli"
  exit 1
fi

# Check if .dot-secrets repository exists
if [ ! -d "$DOT_SECRETS_DIR" ]; then
  echo "Error: .dot-secrets directory not found at $DOT_SECRETS_DIR"
  echo "Please clone your .dot-secrets repository to your home directory:"
  echo "  git clone git@github.com:yourusername/.dot-secrets.git ~/.dot-secrets"
  exit 1
fi

# Check if Kubernetes config file exists in .dot-secrets
if [ ! -f "$KUBE_CONFIG_FILE" ]; then
  echo "Kubernetes config file not found in .dot-secrets"
  echo "Creating the directory structure..."
  mkdir -p "$KUBE_CONFIG_DIR"
  
  echo "Copying the template config..."
  if [ -f "$TEMPLATE_DIR/config.sh" ]; then
    cp "$TEMPLATE_DIR/config.sh" "$KUBE_CONFIG_FILE"
    chmod +x "$KUBE_CONFIG_FILE"
    echo "Template copied to $KUBE_CONFIG_FILE"
    echo "Please edit this file with your company-specific settings before running this script again."
    exit 1
  else
    echo "Error: Template config not found at $TEMPLATE_DIR/config.sh"
    echo "Please create the config file manually in $KUBE_CONFIG_FILE"
    exit 1
  fi
fi

# Source the company-specific configuration
echo "Loading company-specific Kubernetes configuration..."
source "$KUBE_CONFIG_FILE"

# Validate required variables
if [ -z "$KUBE_CONFIG_URL" ] || [ -z "$KUBE_CONFIG_FILENAME" ] || [ -z "$DEFAULT_CONTEXT" ]; then
  echo "Error: Missing required configuration variables in $KUBE_CONFIG_FILE"
  echo "Please ensure KUBE_CONFIG_URL, KUBE_CONFIG_FILENAME, and DEFAULT_CONTEXT are set."
  exit 1
fi

# Create the .kube directory if it doesn't exist
mkdir -p "$HOME/.kube"

# Check if we can access the company URL (VPN check)
echo "Checking VPN connectivity to company resources..."
if curl --connect-timeout 5 -s --head "$KUBE_CONFIG_URL" >/dev/null; then
  echo "VPN connection detected. Proceeding with download..."
  
  # Download the company's kubectl config
  echo "Downloading company kubectl configuration from $KUBE_CONFIG_URL..."
  if command -v curl &> /dev/null; then
    curl --connect-timeout 10 -s -o "$HOME/.kube/$KUBE_CONFIG_FILENAME" "$KUBE_CONFIG_URL"
  elif command -v wget &> /dev/null; then
    wget --timeout=10 -q -O "$HOME/.kube/$KUBE_CONFIG_FILENAME" "$KUBE_CONFIG_URL"
  else
    echo "Error: Neither curl nor wget is installed. Cannot download kubectl config."
    exit 1
  fi

  # Check if the download was successful
  if [ ! -f "$HOME/.kube/$KUBE_CONFIG_FILENAME" ]; then
    echo "Error: Failed to download kubectl config from $KUBE_CONFIG_URL"
    echo "Please check your network connection and the URL."
    exit 1
  fi
  
  # Set the KUBECONFIG environment variable for this session
  export KUBECONFIG="$HOME/.kube/$KUBE_CONFIG_FILENAME"

  # Add the KUBECONFIG to shell profile if not already there
  for PROFILE in "$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.bash_profile"; do
    if [ -f "$PROFILE" ]; then
      if ! grep -q "KUBECONFIG.*$KUBE_CONFIG_FILENAME" "$PROFILE"; then
        echo "Adding KUBECONFIG to $PROFILE"
        echo "" >> "$PROFILE"
        echo "# Kubernetes configuration" >> "$PROFILE"
        echo "export KUBECONFIG=\"\$HOME/.kube/$KUBE_CONFIG_FILENAME\"" >> "$PROFILE"
      fi
    fi
  done

  # List available contexts
  echo "Available Kubernetes contexts:"
  kubectl config get-contexts

  # Set the default context
  echo "Setting default context to $DEFAULT_CONTEXT"
  kubectl config use-context "$DEFAULT_CONTEXT"

  # Test the connection
  echo "Testing connection to Kubernetes cluster..."
  if kubectl get namespaces --request-timeout=5s &> /dev/null; then
    echo "Connection successful!"
    kubectl get namespaces
  else
    echo "Warning: Could not connect to Kubernetes cluster"
    echo "This could be due to:"
    echo "  1. VPN not connected properly"
    echo "  2. Invalid context"
    echo "  3. Network issues"
    echo ""
    echo "Please check your connection and try again."
  fi

  echo ""
  echo "Kubernetes configuration setup complete!"
  echo "You can switch contexts using: kubectl config use-context <context-name>"
  echo "Available contexts can be listed using: kubectl config get-contexts"
else
  echo "VPN connection not detected or company resources not accessible."
  echo "Cannot download Kubernetes configuration without VPN connection."
  echo "Please connect to the company VPN and run this script again."
  echo ""
  echo "Skipping Kubernetes configuration for now."
  exit 0
fi 