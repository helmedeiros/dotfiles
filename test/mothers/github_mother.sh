#!/usr/bin/env bash

# Mock GitHub API responses
setup_github_mocks() {
    local test_dir="${1}"
    local mock_dir="${test_dir}/mocks"
    mkdir -p "${mock_dir}"

    # Create mock curl function
    cat > "${mock_dir}/curl" << 'EOF'
#!/usr/bin/env bash

# Mock responses based on URL
if [[ "$*" == *"/packages/npm/"* ]]; then
    if [[ "$*" == *"/versions?"* ]]; then
        # Mock version list response
        echo '[{"id": "1", "name": "1.0.0"}, {"id": "2", "name": "1.0.1"}]'
    else
        # Mock package info response
        echo '{"version_count": 25}'
    fi
else
    # Mock error response
    echo '{"message": "Not Found"}'
    exit 1
fi
EOF

    chmod +x "${mock_dir}/curl"
    export PATH="${mock_dir}:${PATH}"
}

# Create test configuration
setup_github_config() {
    local test_dir="${1}"
    local config_dir="${test_dir}/.dot-secrets/github"
    mkdir -p "${config_dir}"

    cat > "${config_dir}/packages.sh" << 'EOF'
export GH_PACKAGES_TOKEN="test_token"
export ORG="test_org"
export REPO="test_repo"
export VERSIONS_TO_KEEP=10
EOF
}
