# tracer

Internal `tracer` CLI — built from source via Go.

## What `install.sh` does

Clones the tracer repository to `$HOME/.tracer`, then runs `make dev-deps` and `make install`. Requires Go on `PATH` (errors out otherwise). Also runs `tracer configure --autocomplete` to register shell completions.

## What gets loaded into your shell

- `path.zsh` — exports `TRACER_HOME` and prepends `$TRACER_HOME/bin` to `PATH`.
