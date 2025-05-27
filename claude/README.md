# Claude

This directory contains scripts for installing and managing Anthropic's Claude products:

1. **Claude Desktop App** - Official desktop application for Claude AI
2. **Claude Code** - AI-assisted development tool for coding with Claude

## Installation

Run the install script:

```bash
./install.sh
```

This will install:

- The Claude desktop app via Homebrew cask
- Claude Code via npm
- Required dependencies (Node.js 18+ and ripgrep)
- Setup the Claude Code configuration file

## Claude Desktop App

The Claude desktop app provides a native macOS experience for interacting with Claude AI.

## Claude Code

Claude Code is an agentic coding tool that lives in your terminal, understands your codebase, and helps you code faster through natural language commands.

### System Requirements

- **Operating Systems**: macOS 10.15+ (your system meets this requirement)
- **Hardware**: 4GB RAM minimum
- **Software**:
  - Node.js 18+ (installed by our script)
  - git 2.23+ (optional)
  - GitHub or GitLab CLI for PR workflows (optional)
  - ripgrep (rg) for enhanced file search (installed by our script)

### Authentication

When you first run `claude` in your project directory, you'll need to authenticate. Claude Code offers multiple authentication options:

1. **Anthropic Console**: The default option. Connect through the Anthropic Console and complete the OAuth process. Requires active billing at console.anthropic.com.
2. **Claude App (with Max plan)**: If you have a Claude Max plan subscription.
3. **Enterprise platforms**: Claude Code can be configured to use Amazon Bedrock or Google Vertex AI for enterprise deployments.

### Usage

Basic commands:

```bash
# Start interactive mode
claude

# Start with an initial query
claude "explain this project"

# Run a single command and exit
claude -p "what does this function do?"

# Process piped content
cat logs.txt | claude -p "analyze these errors"
```

### Project Initialization

For new projects, it's recommended to:

1. Start Claude Code: `claude`
2. Generate a CLAUDE.md project guide: `/init`
3. Commit the generated CLAUDE.md file

An example `CLAUDE.md.example` file is included in this directory for reference.

### Configuration

Claude Code configuration is stored in `~/.config/claude-code/config.json`. Our install script creates this file using the template provided in this directory (`claude-config.json`).

To modify configuration via the CLI, run:

```bash
claude config
```

You can also edit the configuration file directly.

### Additional Resources

- [Official Documentation](https://docs.anthropic.com/en/docs/claude-code/overview)
- [Getting Started Guide](https://docs.anthropic.com/en/docs/claude-code/getting-started)
