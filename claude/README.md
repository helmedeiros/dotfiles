# Claude

This directory manages the [Claude](https://www.anthropic.com/claude) desktop app, the [Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview) CLI, and the persistence stack that keeps important context from being lost across sessions, machines, and projects.

## Installation

Run the install script:

```bash
./install.sh
```

This will install:

- The Claude desktop app via Homebrew cask
- Claude Code CLI via Homebrew cask
- ripgrep for enhanced file search
- The user-global `~/.claude/CLAUDE.md` symlink (preferences shared across every session)
- The [clean-code-skills](https://github.com/helmedeiros/clean-code-skills) plugin into `~/.claude/plugins/clean-code-skills/`

beads (the `bd` CLI) is installed via the top-level `Brewfile`.

## The four-layer persistence model

Claude Code drops context across sessions, machines, and projects unless you give it a place to put it. The dotfiles configure four complementary layers:

| Layer | Storage | What it holds | Scope |
| --- | --- | --- | --- |
| Behaviour / methodology | `~/.claude/plugins/clean-code-skills/` | TDD, SOLID, refactoring, hexagonal, clean code | User-global, auto-discovered |
| User-global facts | `~/.claude/CLAUDE.md` (symlinked from `claude/CLAUDE.md`) | Style, commit conventions, terse-mode | User-global |
| Per-project structured memory | beads `.beads/` (managed by `bd`) | Tasks, decisions, `bd remember` insights | Per-repo, git-tracked |
| Per-project free-form | repo-level `CLAUDE.md` + harness auto-memory | Architecture notes, ad-hoc observations | Per-repo |

Skills are not memory — they are knowledge Claude reaches for when relevant. Beads is the structured project memory. The two CLAUDE.md files (global and per-repo) carry preferences and project conventions. Together they replace the previous all-or-nothing reliance on auto-memory.

## Bootstrapping a new project

Inside any repo you want to take seriously, run:

```bash
claude-bootstrap                  # bd init + bd setup claude
claude-bootstrap --with-claude-md # also drop a CLAUDE.md template
```

The script is idempotent — re-running it is safe. It refuses to clobber an existing `CLAUDE.md` and skips `bd init` if `.beads/` is already present.

## Claude Code

Claude Code is an agentic coding tool that lives in your terminal, understands your codebase, and helps you code through natural language commands.

### System Requirements

- **Operating Systems**: macOS 10.15+
- **Hardware**: 4GB RAM minimum
- **Software**:
  - Homebrew (for installation)
  - git 2.23+
  - GitHub or GitLab CLI for PR workflows (optional)
  - ripgrep (installed by this script)

### Updating Claude Code

Homebrew casks do not auto-update. To get the latest features and security fixes:

```bash
brew upgrade --cask claude-code
```

### Authentication

When you first run `claude` in a project directory, you will need to authenticate. Claude Code supports:

1. **Anthropic Console** — the default; OAuth via [console.anthropic.com](https://console.anthropic.com) with active billing.
2. **Claude App (Max plan)** — if you have a Claude Max subscription.
3. **Enterprise platforms** — Amazon Bedrock or Google Vertex AI for enterprise deployments.

### Usage

```bash
claude                                  # interactive
claude "explain this project"           # interactive with an initial query
claude -p "what does this function do?" # one-shot
cat logs.txt | claude -p "analyze these errors"
```

### Configuration

Claude Code is configured via `~/.claude/settings.json` (global) and per-project `<repo>/.claude/settings.json` files. `bd setup claude` writes the per-project hook configuration; the global file is left machine-local on purpose. To modify configuration via the CLI:

```bash
claude config
```

## Working with the layers

| Where to add it | When |
| --- | --- |
| `claude/CLAUDE.md` (then re-run `./install.sh`) | A cross-project preference: tone, commit rules, default tools |
| Repo-level `CLAUDE.md` | Project-specific conventions, build/test commands, gotchas |
| `bd remember "..."` | A non-obvious decision or insight worth recalling in a future session |
| `bd create` / `bd update` | A task with structure: dependencies, status, blockers |
| `claude/install.sh` | A new global plugin or tool that should land on every machine |

## Additional resources

- [Claude Code documentation](https://docs.anthropic.com/en/docs/claude-code/overview)
- [Getting started with Claude Code](https://docs.anthropic.com/en/docs/claude-code/getting-started)
- [clean-code-skills](https://github.com/helmedeiros/clean-code-skills)
- [beads](https://github.com/steveyegge/beads)
