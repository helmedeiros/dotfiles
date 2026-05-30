#!/usr/bin/env bash
#
# Wire the pre-commit framework into this repo so .pre-commit-config.yaml
# runs on every commit. Pre-commit itself is installed via the Brewfile.
#
# Idempotent: `pre-commit install` rewrites .git/hooks/pre-commit each
# time but the result is the same.

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG="${REPO_ROOT}/.pre-commit-config.yaml"

if ! command -v pre-commit &> /dev/null; then
    echo "  pre-commit not on PATH. Run 'brew install pre-commit' (or 'brew bundle' from \$ZSH) first."
    exit 0
fi

if [ ! -f "${CONFIG}" ]; then
    echo "  No .pre-commit-config.yaml at repo root, skipping."
    exit 0
fi

echo "  Installing pre-commit hooks for $(basename "${REPO_ROOT}")"
(cd "${REPO_ROOT}" && pre-commit install --install-hooks)
