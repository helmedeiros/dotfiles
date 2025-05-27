#!/bin/bash
#
# Install Claude
#
# This follows the dotfiles contract and installs:
# 1. The Claude desktop app via Homebrew cask
# 2. Claude Code for AI-assisted development

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

# Setup NVM environment like bin/dot does
export NVM_DIR="$HOME/.nvm"
export NVM_AUTO_USE=false

# Source the existing NVM configuration
DOTFILES_DIR="$HOME/.dotfiles"
if [ -f "$DOTFILES_DIR/node/path.zsh" ]; then
    echo -e "${BLUE}Loading NVM environment...${NC}"
    source "$DOTFILES_DIR/node/path.zsh" > /dev/null 2>&1

    # Check if NVM is available and use Node.js 20.17.0 like bin/dot
    if command -v nvm &> /dev/null; then
        # Use Node.js 20.17.0 to match bin/dot
        nvm use 20.17.0 --silent > /dev/null 2>&1 || {
            echo -e "${YELLOW}Node.js 20.17.0 not found, installing...${NC}"
            nvm install 20.17.0
            nvm use 20.17.0 --silent > /dev/null 2>&1
        }
        echo -e "${GREEN}Using Node.js $(node -v) for Claude Code installation${NC}"
    else
        echo -e "${RED}NVM not properly loaded. Please run node/install.sh first${NC}"
        exit 1
    fi
else
    echo -e "${RED}NVM configuration not found. Please run node/install.sh first${NC}"
    exit 1
fi

# Install or update Claude Code using the NVM Node.js environment
if command -v claude &> /dev/null; then
    current_version=$(claude --version 2>/dev/null | awk '{print $1}' || echo "unknown")
    echo -e "${GREEN}Claude Code is installed (version: ${current_version})${NC}"

    # Check if it's outdated and update if needed
    echo -e "${BLUE}Checking for Claude Code updates...${NC}"
    npm update -g @anthropic-ai/claude-code --silent || {
        echo -e "${YELLOW}Update check failed, reinstalling...${NC}"
        npm install -g @anthropic-ai/claude-code
    }

    new_version=$(claude --version 2>/dev/null | awk '{print $1}' || echo "unknown")
    if [ "$current_version" != "$new_version" ]; then
        echo -e "${GREEN}Claude Code updated from ${current_version} to ${new_version}${NC}"
    else
        echo -e "${GREEN}Claude Code is up to date${NC}"
    fi
else
    echo -e "${BLUE}Installing Claude Code...${NC}"
    npm install -g @anthropic-ai/claude-code

    # Check if installation succeeded
    if command -v claude &> /dev/null; then
        echo -e "${GREEN}Claude Code installed successfully!${NC}"
        echo -e "Version: $(claude --version)"
    else
        echo -e "${RED}Failed to install Claude Code${NC}"
        echo -e "Please check the error messages above"
        exit 1
    fi
fi

# Install ripgrep for enhanced file search (idempotent)
if ! command -v rg &> /dev/null; then
    echo -e "${BLUE}Installing ripgrep for enhanced file search...${NC}"
    brew install ripgrep
else
    echo -e "${GREEN}ripgrep already installed${NC}"
fi

# Setup Claude Code configuration (idempotent)
CONFIG_DIR="$HOME/.config/claude-code"
CONFIG_FILE="$CONFIG_DIR/config.json"

if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${BLUE}Setting up Claude Code configuration...${NC}"
    mkdir -p "$CONFIG_DIR"
    echo -e "Creating configuration file at $CONFIG_FILE"
    cp "$(dirname "$0")/claude-config.json" "$CONFIG_FILE"
    echo -e "${GREEN}Configuration file created.${NC}"
else
    echo -e "${GREEN}Configuration file already exists.${NC}"
fi

echo -e "${GREEN}Claude setup completed!${NC}"
