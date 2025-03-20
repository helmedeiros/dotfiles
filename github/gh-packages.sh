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
: "${GH_PACKAGES_TOKEN:=""}"
: "${ORG:=""}"
: "${REPO:=""}"
: "${VERSIONS_TO_KEEP:=20}"

# Validate required parameters
if [ -z "$GH_PACKAGES_TOKEN" ] || [ -z "$ORG" ] || [ -z "$REPO" ]; then
    echo "Error: Missing required parameters"
    echo "Please set up your configuration in ${GITHUB_SECRETS_FILE} or provide them as environment variables:"
    echo "Usage: GH_PACKAGES_TOKEN=your_token ORG=your_org REPO=your_repo ./gh-packages.sh"
    exit 1
fi

fetch_number_of_versions () {
    local response
    response=$(curl -s \
        -H "Accept: application/vnd.github.v3+json" \
        -H "Authorization: Bearer ${GH_PACKAGES_TOKEN}" \
        "https://api.github.com/orgs/${ORG}/packages/npm/${REPO}")

    # Check if the response contains an error message
    if echo "$response" | jq -e '.message' >/dev/null 2>&1; then
        local error_msg
        error_msg=$(echo "$response" | jq -r '.message')
        if [[ "$error_msg" == "Package not found." ]]; then
            echo "0"
            return 0
        fi
        echo "Error: ${error_msg}" >&2
        exit 1
    fi

    local count
    count=$(echo "$response" | jq -r .version_count)
    if ! [[ "$count" =~ ^[0-9]+$ ]]; then
        echo "Error: Invalid version count" >&2
        exit 1
    fi
    echo "$count"
}

fetch_oldest_version () {
    local version_count="${1}"
    local last_page=$(((version_count + 29) / 30))
    local response
    local oldest_version=""
    local oldest_version_name=""

    # Try each page from last_page down to 1 to find the oldest version
    for ((page=last_page;page>=1;page--)); do
        response=$(curl -s \
            -H "Accept: application/vnd.github.v3+json" \
            -H "Authorization: Bearer ${GH_PACKAGES_TOKEN}" \
            "https://api.github.com/orgs/${ORG}/packages/npm/${REPO}/versions?per_page=30&page=${page}")

        # Check if the response contains an error message
        if echo "$response" | jq -e '.message' >/dev/null 2>&1; then
            local error_msg
            error_msg=$(echo "$response" | jq -r '.message')
            if [[ "$error_msg" == "Package not found." ]]; then
                continue
            fi
            echo "Error: ${error_msg}" >&2
            exit 1
        fi

        # Check if we got any versions
        if [ "$(echo "$response" | jq '. | length')" -gt 0 ]; then
            # Process each version in the page
            local versions
            versions=$(echo "$response" | jq -c '.[]')
            while IFS= read -r version; do
                local version_name
                version_name=$(echo "$version" | jq -r .name)
                if [ -z "$oldest_version" ] || [ "$(printf '%s\n' "$version_name" "$oldest_version_name" | sort -V | head -n1)" = "$version_name" ]; then
                    oldest_version="$version"
                    oldest_version_name="$version_name"
                fi
            done <<< "$versions"
            # If we found a version on this page, stop searching
            if [ -n "$oldest_version" ]; then
                break
            fi
        fi
    done

    # If we found any versions, return the oldest one
    if [ -n "$oldest_version" ]; then
        echo "$oldest_version"
        return 0
    fi

    # If we get here, we didn't find any versions
    echo "Error: No versions found" >&2
    exit 1
}

package_version () {
    echo "${1}" | jq -r .name
}

package_id () {
    echo "${1}" | jq -r .id
}

# Compare two version strings
# Returns 0 if version1 is older than version2
# Returns 1 if version1 is newer than version2
compare_versions () {
    local version1="${1}"
    local version2="${2}"

    # Remove quotes from version strings
    version1="${version1//\"/}"
    version2="${version2//\"/}"

    if [ "$version1" = "$version2" ]; then
        return 0
    fi

    # Compare versions using sort -V
    if [ "$(printf '%s\n' "$version2" "$version1" | sort -V | head -n1)" = "$version1" ]; then
        return 0
    else
        return 1
    fi
}

delete_version () {
    local version_id="${1}"
    local response

    response=$(curl -s -XDELETE \
        -H "Accept: application/vnd.github.v3+json" \
        -H "Authorization: Bearer ${GH_PACKAGES_TOKEN}" \
        "https://api.github.com/orgs/${ORG}/packages/npm/${REPO}/versions/${version_id}" 2>&1)

    # Check if the response contains an error message
    if echo "$response" | jq -e '.message' >/dev/null 2>&1; then
        local error_msg
        error_msg=$(echo "$response" | jq -r '.message')
        echo "Error: ${error_msg}" >&2
        return 1
    fi
    return 0
}

# Main script
echo "Cleaning up old versions of ${ORG}/${REPO} npm package..."
echo "Will keep the ${VERSIONS_TO_KEEP} most recent versions."

versions=$(fetch_number_of_versions)
echo "Found ${versions} versions."

if [ "$versions" -le "$VERSIONS_TO_KEEP" ]; then
    echo "No cleanup needed. Exiting."
    exit 0
fi

versions_to_delete=$((versions - VERSIONS_TO_KEEP))
deleted_count=0
while [ "$deleted_count" -lt "$versions_to_delete" ]; do
    last=$(fetch_oldest_version "$versions")
    version_name=$(package_version "${last}")
    version_id=$(package_id "${last}")
    echo "Deleting version ${version_name} (ID: ${version_id})"
    if ! delete_version "${version_id}"; then
        echo "Failed to delete version ${version_name}. Aborting cleanup." >&2
        exit 1
    fi
    deleted_count=$((deleted_count + 1))
    # Update version count after successful deletion
    versions=$((versions - 1))
done

echo "Cleanup complete. Kept the ${VERSIONS_TO_KEEP} most recent versions."
