#!/bin/bash
# Kubernetes configuration
# Copy this file to ~/.dot-secrets/kubernetes/config.sh and update with your values

# URL to download your Kubernetes configuration file
# Replace with your company's specific URL
KUBE_CONFIG_URL="https://your-company-domain.com/kubernetes/config"

# Filename to save the Kubernetes configuration as
KUBE_CONFIG_FILENAME="config"

# Default Kubernetes context to use
# This should match one of the contexts in your config file
DEFAULT_CONTEXT="your-default-context"

# Additional company-specific environment variables can be added here
# COMPANY_NAMESPACE="your-namespace"
# COMPANY_REGISTRY="your-registry.company.com"

# Optional: Set to true if VPN is required to connect
# COMPANY_VPN_REQUIRED=true

# Optional: Proxy settings if needed
# COMPANY_PROXY="" 