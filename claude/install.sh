#!/bin/bash
#
# Install Claude
#
# This follows the dotfiles contract and installs:
# 1. The Claude desktop app via Homebrew cask
# 2. Claude Code CLI via Homebrew cask

set -e

# Colors for output
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

printf '%b\n' "${BLUE}Setting up Claude...${NC}"

# Install Claude desktop app via Homebrew (idempotent)
if ! brew list --cask claude &>/dev/null; then
    printf '%b\n' "${BLUE}Installing Claude desktop app...${NC}"
    brew install --cask claude
else
    printf '%b\n' "${GREEN}Claude desktop app already installed${NC}"
fi

# Install Claude Code CLI via Homebrew (idempotent)
# Note: Homebrew casks don't auto-update, run 'brew upgrade claude-code' periodically
if ! brew list --cask claude-code &>/dev/null; then
    printf '%b\n' "${BLUE}Installing Claude Code CLI...${NC}"
    brew install --cask claude-code
else
    printf '%b\n' "${GREEN}Claude Code CLI already installed${NC}"
    # Check for updates
    printf '%b\n' "${BLUE}Checking for Claude Code updates...${NC}"
    if brew outdated --cask claude-code &>/dev/null; then
        printf '%b\n' "${YELLOW}Updating Claude Code...${NC}"
        brew upgrade --cask claude-code || printf '%b\n' "${YELLOW}Update not yet available in Homebrew, try again later${NC}"
    else
        printf '%b\n' "${GREEN}Claude Code is up to date${NC}"
    fi
fi

# Verify installation
if command -v claude &> /dev/null; then
    printf '%b\n' "${GREEN}Claude Code installed successfully!${NC}"
    claude --version
else
    printf '%b\n' "${RED}Claude Code installation could not be verified${NC}"
    printf '%b\n' "${YELLOW}You may need to restart your terminal${NC}"
fi

# Install ripgrep for enhanced file search (idempotent)
if ! command -v rg &> /dev/null; then
    printf '%b\n' "${BLUE}Installing ripgrep for enhanced file search...${NC}"
    brew install ripgrep
else
    printf '%b\n' "${GREEN}ripgrep already installed${NC}"
fi

# Source helper functions
CLAUDE_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib.sh
. "$CLAUDE_DIR/lib.sh"

# Symlink user-global CLAUDE.md into ~/.claude/
printf '%b\n' "${BLUE}Linking user-global CLAUDE.md...${NC}"
if link_claude_file "$CLAUDE_DIR/CLAUDE.md" "$HOME/.claude/CLAUDE.md"; then
    printf '%b\n' "${GREEN}~/.claude/CLAUDE.md linked${NC}"
else
    printf '%b\n' "${RED}Failed to link ~/.claude/CLAUDE.md${NC}"
fi

# Symlink user-global skills into ~/.claude/skills/ (one symlink per skill dir).
# Two sources: this public repo (agnostic skills, if any) and the private
# .dot-secrets repo (personal skills — kept out of the public repo). Later
# sources win on name collisions, but the two dirs are expected to be disjoint.
: "${DOT_SECRETS_ROOT:=$HOME/.dot-secrets}"
link_skills_from() {
    local dir="$1"
    [ -d "$dir" ] || return 0
    for skill in "$dir"/*/; do
        [ -d "$skill" ] || continue
        local name
        name="$(basename "$skill")"
        if link_claude_file "${skill%/}" "$HOME/.claude/skills/$name"; then
            printf '%b\n' "${GREEN}  ~/.claude/skills/$name linked${NC}"
        else
            printf '%b\n' "${RED}  Failed to link skill: $name${NC}"
        fi
    done
}
printf '%b\n' "${BLUE}Linking user-global skills...${NC}"
link_skills_from "$CLAUDE_DIR/skills"
link_skills_from "$DOT_SECRETS_ROOT/claude/skills"

# Check beads is available (installed via Brewfile)
if command -v bd &> /dev/null; then
    printf '%b\n' "${GREEN}beads (bd) already installed${NC}"
else
    printf '%b\n' "${YELLOW}beads not on PATH. Run 'brew bundle' from \$ZSH or 'brew install beads'.${NC}"
fi

# Install the clean-code-skills plugin (TDD, SOLID, refactoring, etc.)
printf '%b\n' "${BLUE}Installing clean-code-skills plugin...${NC}"
if install_git_plugin \
    "https://github.com/helmedeiros/clean-code-skills.git" \
    "$HOME/.claude/plugins/clean-code-skills"; then
    printf '%b\n' "${GREEN}clean-code-skills plugin ready${NC}"
else
    printf '%b\n' "${YELLOW}clean-code-skills plugin install skipped${NC}"
fi

printf '%b\n' "${GREEN}Claude setup completed!${NC}"
