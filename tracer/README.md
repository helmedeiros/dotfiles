# tracer

The [`tracer`](https://github.com/helmedeiros/tracer-bullet) CLI.

## What this topic does

- **`install.sh`** (run by `bin/dot`) `go install`s the `tracer` binary into
  `$GOPATH/bin` (already on `PATH` via `go/path.zsh`) and regenerates the zsh
  completion.
- **`_tracer`** is the generated completion; `zsh/fpath.zsh` adds this topic to
  `fpath`, so `tracer <Tab>` works.
