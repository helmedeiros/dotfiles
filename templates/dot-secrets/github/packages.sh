#!/bin/bash
#
# GitHub Packages Configuration
# Copy this file to ~/.dot-secrets/github/packages.sh and update with your values
#

# GitHub Personal Access Token with packages:read and packages:delete permissions
export GH_PACKAGES_TOKEN="your_github_token_here"

# Your GitHub organization name (optional)
export ORG="your_organization"

# Your GitHub repository name (optional)
export REPO="your_repository"

# Number of versions to keep (optional, defaults to 20)
export VERSIONS_TO_KEEP=20 