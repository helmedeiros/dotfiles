# Ollama

[Ollama](https://ollama.com) — local LLM runner. Installed via the Brewfile.

## What `install.sh` does

- Verifies `ollama` is on `PATH` (errors out if not — run `bin/dot` first).
- Starts the `ollama` brew service if not already running.
- `ollama pull`s any models listed in the `MODELS` array (currently just `llama3`) that aren't already present.

Idempotent — already-running service and already-pulled models are no-ops.
