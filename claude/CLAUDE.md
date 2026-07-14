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

## Project memory (beads)

Per-project structured memory is managed with [beads](https://github.com/steveyegge/beads) (the `bd` CLI). When a repo is initialised with beads, a SessionStart hook runs `bd prime` at the start of every session to inject stored insights and the current task graph.

- Use `bd remember "..."` to persist non-obvious decisions, gotchas, or context that would be valuable to recall in a future session.
- Use `bd ready` to see unblocked tasks, `bd create` to add new ones, `bd update --claim` to take one.
- Prefer beads over markdown TODO lists for any work that spans more than one session.

## Second brain (personal knowledge graph)

A local knowledge graph of my past professional work (2,200+ atomic concepts distilled from my ChatGPT history and work documents) lives at `~/second-brain`. When I ask about my own past work — decisions, projects, people, systems, metrics, or conventions from my work history (pricing, insurance/ancillaries, product/agile, leadership, engineering, AI/ML) — consult it instead of guessing:

- Query it with `brain "<topic>"` (add `--domain <name>` or `--full`; `brain --list-domains` lists domains). Fast, local, no cost.
- Whole-domain overview: `~/second-brain/generated/<Domain>.md`; root index `Home.md`. A concept's full detail: `~/second-brain/nodes/<type>/<id>.md`.
- Ground answers in what it returns and cite concept ids; if it has nothing relevant, say so rather than inventing unsupported facts. The `/second-brain` skill wraps this flow.
