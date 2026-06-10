# dotfiles

A personal macOS development environment in one repository. Clone it on a fresh laptop, run two commands, and end up with shell, terminal, languages, window manager, GUI apps, and AI-coding tooling configured.

## What you get

- A configured zsh shell (powerlevel10k prompt, syntax highlighting, autosuggestions, zoxide for fast directory jumps)
- Terminal theming for Terminal.app and iTerm2 (Solarized Dark) plus a [Ghostty](ghostty/) config
- Homebrew-managed CLI tools, casks, and language toolchains (Go, Node via nvm, Python via pyenv, JVM stack via [SDKMAN](sdkman/), Ruby via rbenv)
- macOS system defaults (Finder, Dock, trackpad, keyboard) applied automatically
- A tiling window manager stack ([yabai](yabai/) + [skhd](skhd/)) and key remapping via [Karabiner Elements](karabiner/)
- A custom `bin/` of git, search, and housekeeping scripts on `PATH` everywhere — see [`bin/README.md`](bin/README.md)
- A four-layer persistence stack for [Claude Code](claude/) so AI-assisted work doesn't lose context between sessions, projects, or machines
- A daily update checker that nags you about stale Homebrew packages, npm globals, and out-of-date dotfiles, with one-command updates

## Quickstart

```sh
git clone https://github.com/helmedeiros/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
script/bootstrap
bin/dot
```

The two scripts do different jobs:

- `script/bootstrap` symlinks every `*.symlink` file into `$HOME` (e.g. `zsh/zshrc.symlink` becomes `~/.zshrc`), prompts you for git author info on first run, and clones your private `.dot-secrets` repository if you have one.
- `bin/dot` installs Homebrew if missing, runs every `topic/install.sh` (Brewfile included), and applies macOS defaults. Re-run it any time to keep your machine in sync.

The first place you'll usually want to edit is [`zsh/zshrc.symlink`](zsh/zshrc.symlink) — it holds machine-specific paths and exports.

## How it's organised

The repository is a flat list of topic directories. Each topic owns one tool or one concern:

```
claude/        Claude Code preferences, plugins, bootstrap helper
docker/        Docker Desktop launch + aliases
git/           gitconfig, gitignore, helper scripts
go/            Go toolchain + global packages
karabiner/     Keyboard remapping rules
node/          nvm + global npm packages
yabai/         Tiling window manager config
...
```

When `bin/dot` runs, it walks every topic and applies a small set of conventions:

| File in a topic dir | What happens |
| --- | --- |
| `install.sh` | Executed once during `bin/dot`. Idempotent — safe to re-run. |
| `path.zsh` | Sourced first when a new shell starts. Use it to set `PATH` and export env vars. |
| `*.zsh` (other) | Sourced on shell startup after `path.zsh`. Aliases, functions, completions. |
| `completion.zsh` | Sourced last. Use for tools whose completions depend on other state. |
| `*.symlink` | Symlinked into `$HOME` (dropping the suffix) by `script/bootstrap`. |
| `README.md` | Human-readable description of the topic. Read this before editing. |

The top-level [`Brewfile`](Brewfile) lists every Homebrew formula and cask. It's executed early in `bin/dot`.

## Day-to-day usage

Run `bin/dot` whenever you want to refresh your environment — it's idempotent, so re-runs only pick up new or outdated bits.

A background update checker runs once a day when you open a new shell. When something is stale you'll see indicators in your prompt (e.g. `[DOTFILES UPDATE]`, `[BREW UPDATE]`, `[NPM UPDATE]`). Two commands wrap the workflow:

```sh
dotfiles-update-check     # report what's behind, optionally pull
dotfiles-apply-updates    # apply pending updates and clear the prompt indicators
```

Both are defined in [`zsh/update.zsh`](zsh/update.zsh) and use the same machinery as `bin/check-updates`.

## AI-assisted development

The [`claude/`](claude/) topic configures [Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview) with a four-layer persistence model so context survives across sessions, machines, and projects:

1. **Behaviour / methodology** — TDD, SOLID, refactoring, hexagonal-architecture skills auto-loaded from [`helmedeiros/clean-code-skills`](https://github.com/helmedeiros/clean-code-skills) installed into `~/.claude/plugins/`.
2. **User-global facts** — `~/.claude/CLAUDE.md` symlinked from this repo. Cross-project style and commit preferences.
3. **Per-project structured memory** — [beads](https://github.com/steveyegge/beads) (the `bd` CLI) installed via Brewfile. Tasks, decisions, and `bd remember` insights tracked per repo.
4. **Per-project free-form** — each repo's own `CLAUDE.md`, plus the Claude Code harness's auto-memory.

To wire beads into a new repo:

```sh
claude-bootstrap                  # bd init + bd setup claude
claude-bootstrap --with-claude-md # also drop a CLAUDE.md template
```

See [`claude/README.md`](claude/README.md) for the full mental model and which layer to edit when.

## History hygiene

[`bin/history-clean`](bin/history-clean) is for surgically removing entries from your shell history without rewriting the whole file:

```sh
history-clean 42                  # remove line 42
history-clean 10 15 20            # remove multiple lines
history-clean -p "password"       # remove every line containing "password"
history-clean --last 5            # remove the last 5 commands
history-clean --autocomplete      # also clear completion and autosuggestion state
```

Useful after pasting something sensitive into the terminal.

## Adding a new topic

Adding support for a new tool is dropping a directory in:

```
my-new-tool/
  install.sh      # idempotent install / configure steps
  path.zsh        # PATH or env vars
  aliases.zsh     # optional convenience aliases
  README.md       # tell future-you what this is
```

There's no central registry to update. `bin/dot` finds the `install.sh` on its next run; `script/bootstrap` finds any `*.symlink` files in the new dir; zsh sources every `*.zsh` automatically.

## Private configuration

Anything machine-specific or credential-bearing belongs in a private `~/.dot-secrets` repository, not here. Templates for the expected file layout are in [`templates/dot-secrets/`](templates/dot-secrets/). Topics that consume secrets (currently `kubernetes/`, `dbeaver/`, `robo3t/`, `git/`, `myke/`, plus `lint/` for repo-wide PII guards) check for `~/.dot-secrets` during their install and fail with a clear message if it's missing.

### Changing employers

When you change companies, the only edits should be inside `~/.dot-secrets/` — the public dotfiles repo stays employer-agnostic. The full playbook (which file to update, delete, or keep, and the verification commands to run afterwards) lives in `~/.dot-secrets/MIGRATION.md`. If you ever find yourself reaching to edit something *here* for an employer-specific reason, that's a signal the value should move into `.dot-secrets` instead.

## Testing

The dotfiles ship a [BATS](https://github.com/bats-core/bats-core) test suite covering the `bin/` scripts, several topic installers, and repo-wide lint rules.

```sh
./test/run_tests.sh
```

See [`test/README.md`](test/README.md) for layout and conventions.

## Customisation

The whole repository is intended to be forked and edited. Topic directories are independent, so adding, replacing, or deleting one rarely touches anything else. Start by editing `zsh/zshrc.symlink` and the `Brewfile`, then carve out new topic dirs as you bring more tools under management.
