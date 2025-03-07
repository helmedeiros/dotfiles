#!/usr/bin/env bash
#
# GitHub Packages Cleanup Script
# 
# This script cleans up old versions of npm packages in GitHub Packages.
# Configuration is sourced from .dot-secrets if available.
# Usage: ./gh-packages.sh
# Or with manual config: GH_PACKAGES_TOKEN=your_token ORG=your_org REPO=your_repo ./gh-packages.sh
#

set -e

# Source configuration from .dot-secrets if available
DOT_SECRETS_DIR="${HOME}/.dot-secrets"
GITHUB_SECRETS_FILE="${DOT_SECRETS_DIR}/github/packages.sh"

if [ -f "$GITHUB_SECRETS_FILE" ]; then
    echo "Loading configuration from ${GITHUB_SECRETS_FILE}"
    source "$GITHUB_SECRETS_FILE"
fi

# Configuration (can be overridden with environment variables)
GH_PACKAGES_TOKEN=${GH_PACKAGES_TOKEN:-""}
ORG=${ORG:-""}
REPO=${REPO:-""}
VERSIONS_TO_KEEP=${VERSIONS_TO_KEEP:-20}

# Validate required parameters
if [ -z "$GH_PACKAGES_TOKEN" ] || [ -z "$ORG" ] || [ -z "$REPO" ]; then
    echo "Error: Missing required parameters"
    echo "Please set up your configuration in ${GITHUB_SECRETS_FILE} or provide them as environment variables:"
    echo "Usage: GH_PACKAGES_TOKEN=your_token ORG=your_org REPO=your_repo ./gh-packages.sh"
    exit 1
fi

fetch_number_of_versions () {
    curl -s \
        -H "Accept: application/vnd.github.v3+json" \
        -H "Authorization: Bearer ${GH_PACKAGES_TOKEN}" \
        "https://api.github.com/orgs/${ORG}/packages/npm/${REPO}" \
    | jq .version_count
}

fetch_oldest_version () {
    version_count=${1}
    last_page=$(((version_count + 29) / 30))

    curl -s \
        -H "Accept: application/vnd.github.v3+json" \
        -H "Authorization: Bearer ${GH_PACKAGES_TOKEN}" \
        "https://api.github.com/orgs/${ORG}/packages/npm/${REPO}/versions?page=${last_page}" \
    | jq .[-1]
}

delete_version () {
    version_id=${1}

    curl -s -XDELETE \
        -H "Accept: application/vnd.github.v3+json" \
        -H "Authorization: Bearer ${GH_PACKAGES_TOKEN}" \
        "https://api.github.com/orgs/${ORG}/packages/npm/${REPO}/versions/${version_id}"
}

package_version () {
    echo "${1}" | jq .name
}

package_id () {
    echo "${1}" | jq .id
}

echo "Cleaning up old versions of ${ORG}/${REPO} npm package..."
echo "Will keep the ${VERSIONS_TO_KEEP} most recent versions."

versions=$(fetch_number_of_versions)
echo "Found ${versions} versions."

if [ "$versions" -le "$VERSIONS_TO_KEEP" ]; then
    echo "No cleanup needed. Exiting."
    exit 0
fi

for ((i=versions;i>VERSIONS_TO_KEEP;i--)); do
    last=$(fetch_oldest_version ${i})
    echo "Deleting version $(package_version "${last}") (ID: $(package_id "${last}"))"
    delete_version $(package_id "${last}")
done

echo "Cleanup complete. Kept the ${VERSIONS_TO_KEEP} most recent versions."
