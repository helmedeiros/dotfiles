#!/usr/bin/env bash

set -e

GH_PACKAGES_TOKEN=$GH_PACKAGES_TOKEN
REPO=
VERSIONS_TO_KEEP=20

fetch_number_of_versions () {
    curl -s \
        -H "Accept: application/vnd.github.v3+json" \
        -H "Authorization: Bearer ${GH_PACKAGES_TOKEN}" \
        https://api.github.com/orgs/goeuro/packages/npm/${REPO} \
    | jq .version_count
}

fetch_oldest_version () {
    version_count=${1}
    last_page=$(((version_count + 29) / 30))

    curl -s \
        -H "Accept: application/vnd.github.v3+json" \
        -H "Authorization: Bearer ${GH_PACKAGES_TOKEN}" \
        "https://api.github.com/orgs/goeuro/packages/npm/${REPO}/versions?page=${last_page}" \
    | jq .[-1]
}

delete_version () {
    version_id=${1}

    curl -s -XDELETE \
        -H "Accept: application/vnd.github.v3+json" \
        -H "Authorization: Bearer ${GH_PACKAGES_TOKEN}" \
        "https://api.github.com/orgs/goeuro/packages/npm/${REPO}/versions/${version_id}"
}

package_version () {
    echo "${1}" | jq .name
}

package_id () {
    echo "${1}" | jq .id
}

versions=$(fetch_number_of_versions)

for ((i=versions;i>VERSIONS_TO_KEEP;i--)); do
    last=$(fetch_oldest_version ${i})
    echo $i $(package_version "${last}") $(package_id "${last}")
    delete_version $(package_id "${last}")
done
