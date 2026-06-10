# Ruby

[rbenv](https://github.com/rbenv/rbenv) owns Ruby version switching;
[ruby-build](https://github.com/rbenv/ruby-build) is the plugin that
installs new versions. Both are pulled in by the top-level `Brewfile`
(`brew 'rbenv'`, `brew 'ruby-build'`) — there's no `install.sh` here
because Homebrew handles the bootstrap and integrity checks, the same
way `python/` defers JDK-less version management to `brew install pyenv`.

## Day-to-day usage

```sh
rbenv install 3.3.5     # install a specific Ruby
rbenv global 3.3.5      # set the system-wide default
rbenv local 3.3.5       # pin in the current project (.ruby-version)
rbenv versions          # what's installed
```

## What gets loaded into your shell

- `rbenv.zsh` — lazy-loads rbenv. `~/.rbenv/shims` goes on `PATH`
  eagerly so `ruby` / `gem` resolve without overhead, but the full
  `eval "$(rbenv init -)"` only runs on the first `rbenv` invocation.
  Same pattern as `python/path.zsh` and `node/path.zsh`.
- `aliases.zsh` — Rails `script/...` shortcuts (`sc`, `sg`, `sd`).
- `completion.zsh` — rbenv subcommand completion.
- `gemrc.symlink` → `~/.gemrc` — `--no-document` so `gem install`
  doesn't generate rdoc/ri every time.
- `irbrc.symlink` → `~/.irbrc` — irb history + simple prompt.
