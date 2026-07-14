---
name: second-brain
description: Consult Helio's personal knowledge graph ("second brain") — 2,200+ atomic concepts distilled from his ChatGPT history and work documents, across pricing, insurance/ancillaries, product/agile, leadership/management, engineering/platform, and AI/ML. Use when the user asks about their own past work, decisions, projects, people, systems, metrics, or conventions from his professional history (e.g. "what did we decide about X", "how does our Y work", "who owns Z", "continue the work on W"), or explicitly says to check/use their second brain. Grounds answers in the user's real history instead of guessing.
---

# second-brain

A local, model-independent knowledge graph of Helio Medeiros's professional work, at
`~/second-brain` (override with `$SECOND_BRAIN`). Use it to ground answers in his
actual decisions/facts rather than generic advice.

## How to query

1. **Retrieve relevant concepts** with the `brain` command (fast, local, no cost):
   ```sh
   brain "<the user's topic in a few words>"
   brain --domain pricing -n 10 "<topic>"      # focus one domain
   brain --full "<topic>"                        # full statements, not just first line
   brain --list-domains                          # see domains + node counts
   ```
   Domains: `pricing`, `insurance-ancillaries`, `product-agile`,
   `leadership-management`, `engineering-platform`, `ai-ml`.

2. **For a whole-domain overview**, read the map of content:
   `~/second-brain/generated/<Domain>.md` (e.g. `Pricing.md`, `Leadership-Management.md`)
   or the root index `~/second-brain/generated/Home.md`.

3. **For a specific concept's full detail + provenance**, read its node file:
   `~/second-brain/nodes/<type>/<id>.md` (the `id` is printed by `brain`).

## How to answer

- Base the answer on what `brain`/the nodes return. Cite concept titles or ids so
  the user can trace it.
- If the graph has nothing relevant, say so plainly — do NOT invent
  facts (names, numbers, decisions) that aren't in the graph.
- Be concise and decision-oriented. When the user says "continue" work, treat the
  graph as the established history and build forward from the latest state.

## Notes

- The raw source archive (`~/second-brain/archive/`) is the immutable provenance;
  the graph is regenerable from it via `pipeline/build_graph.py`.
- Freshness: nodes carry `next_review`/`ttl_days`; if a fact looks stale relative to
  today, flag it rather than trusting it blindly.
