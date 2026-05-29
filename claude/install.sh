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

echo -e "${BLUE}Setting up Claude...${NC}"

# Install Claude desktop app via Homebrew (idempotent)
if ! brew list --cask claude &>/dev/null; then
    echo -e "${BLUE}Installing Claude desktop app...${NC}"
    brew install --cask claude
else
    echo -e "${GREEN}Claude desktop app already installed${NC}"
fi

# Install Claude Code CLI via Homebrew (idempotent)
# Note: Homebrew casks don't auto-update, run 'brew upgrade claude-code' periodically
if ! brew list --cask claude-code &>/dev/null; then
    echo -e "${BLUE}Installing Claude Code CLI...${NC}"
    brew install --cask claude-code
else
    echo -e "${GREEN}Claude Code CLI already installed${NC}"
    # Check for updates
    echo -e "${BLUE}Checking for Claude Code updates...${NC}"
    if brew outdated --cask claude-code &>/dev/null; then
        echo -e "${YELLOW}Updating Claude Code...${NC}"
        brew upgrade --cask claude-code || echo -e "${YELLOW}Update not yet available in Homebrew, try again later${NC}"
    else
        echo -e "${GREEN}Claude Code is up to date${NC}"
    fi
fi

# Verify installation
if command -v claude &> /dev/null; then
    echo -e "${GREEN}Claude Code installed successfully!${NC}"
    claude --version
else
    echo -e "${RED}Claude Code installation could not be verified${NC}"
    echo -e "${YELLOW}You may need to restart your terminal${NC}"
fi

# Install ripgrep for enhanced file search (idempotent)
if ! command -v rg &> /dev/null; then
    echo -e "${BLUE}Installing ripgrep for enhanced file search...${NC}"
    brew install ripgrep
else
    echo -e "${GREEN}ripgrep already installed${NC}"
fi

# Source helper functions
CLAUDE_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib.sh
. "$CLAUDE_DIR/lib.sh"

# Symlink user-global CLAUDE.md into ~/.claude/
echo -e "${BLUE}Linking user-global CLAUDE.md...${NC}"
if link_claude_file "$CLAUDE_DIR/CLAUDE.md" "$HOME/.claude/CLAUDE.md"; then
    echo -e "${GREEN}~/.claude/CLAUDE.md linked${NC}"
else
    echo -e "${RED}Failed to link ~/.claude/CLAUDE.md${NC}"
fi

# Check beads is available (installed via Brewfile)
if command -v bd &> /dev/null; then
    echo -e "${GREEN}beads (bd) already installed${NC}"
else
    echo -e "${YELLOW}beads not on PATH. Run 'brew bundle' from \$ZSH or 'brew install beads'.${NC}"
fi

# Install the clean-code-skills plugin (TDD, SOLID, refactoring, etc.)
echo -e "${BLUE}Installing clean-code-skills plugin...${NC}"
if install_git_plugin \
    "https://github.com/helmedeiros/clean-code-skills.git" \
    "$HOME/.claude/plugins/clean-code-skills"; then
    echo -e "${GREEN}clean-code-skills plugin ready${NC}"
else
    echo -e "${YELLOW}clean-code-skills plugin install skipped${NC}"
fi

echo -e "${GREEN}Claude setup completed!${NC}"
