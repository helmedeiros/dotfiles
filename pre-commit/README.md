# pre-commit

[pre-commit](https://pre-commit.com) framework wiring for the dotfiles repo itself. Catches the kind of leaks `.github/workflows/security.yml` catches in CI — but at commit time, before anything reaches GitHub.

## Hooks (`.pre-commit-config.yaml`)

- [gitleaks](https://github.com/gitleaks/gitleaks) — secret scan over the staged diff.
- [shellcheck](https://github.com/shellcheck-py/shellcheck-py) — static analysis for shell scripts, mirrors the warning level used in `test/run_tests.sh`.

## What `install.sh` does

- Verifies `pre-commit` is on `PATH` (installed via the Brewfile).
- Runs `pre-commit install --install-hooks` in this repo so `.git/hooks/pre-commit` invokes the framework on every commit.

The first commit after install will be slower because `pre-commit` clones each hook's repo into `~/.cache/pre-commit/`.

## Bypassing

`git commit --no-verify` skips the hooks. Reserve for emergencies — the CI workflow will catch the same issues on push, and dotfiles' own CLAUDE.md forbids `--no-verify` without explicit reason.
