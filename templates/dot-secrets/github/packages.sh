#!/usr/bin/env bash
#
# GitHub Packages Configuration
# Copy this file to ~/.dot-secrets/github/packages.sh and update with your values
#

# GitHub Personal Access Token with packages:read and packages:delete permissions
export GH_PACKAGES_TOKEN="your_github_token_here"

# GitHub Organization name
export ORG="your_organization_name"

# Repository/Package name
export REPO="your_repository_name"

# Number of versions to keep (optional, defaults to 20)
export VERSIONS_TO_KEEP=20 