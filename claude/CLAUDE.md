# Claude Code — user-global preferences

Loaded into every Claude Code session. Per-project conventions belong in each repo's own `CLAUDE.md`.

## Commit style

- Never add Claude (or any AI) as a co-author in commit messages.
- Small, focused commits — one logical change per commit, independently revertable.
- Every commit must leave all quality gates green (lint, format, type-check, tests).
- Follow Conventional Commits: `type(scope): subject`.

## Communication

- Default to terse responses. Skip preamble, headers, and trailing summaries unless asked.
- State decisions directly; do not narrate deliberation.
- When exploring options, give a short recommendation with the main tradeoff before implementing.

## Methodology

Cross-project coding skills (TDD, SOLID, refactoring, hexagonal architecture, clean code) live in `~/.claude/plugins/clean-code-skills/`, cloned from `helmedeiros/clean-code-skills`. They auto-load and trigger when relevant.

To opt out in a repo where they would be overhead (throwaway scripts, exploration), note it in that repo's own `CLAUDE.md`.
