#!/bin/bash
#
# Kubernetes Configuration Variables
# Copy this file to ~/.dot-secrets/kubernetes/config.sh
#
# This file ONLY contains company-specific configuration variables.
# All implementation logic is in the main dotfiles repository.

# URL to download the kubectl config file
KUBE_CONFIG_URL="https://your-company-ci-server.example.com/path/to/kubectl-config"

# Filename to save the kubectl config as
KUBE_CONFIG_FILENAME="company-debug.conf"

# Default Kubernetes context to use
DEFAULT_CONTEXT="dev"

# Optional: Set to true if VPN is required to connect
# COMPANY_VPN_REQUIRED=true

# Optional: Proxy settings if needed
# COMPANY_PROXY="" 