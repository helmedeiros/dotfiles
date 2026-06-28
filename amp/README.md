# amp

The [`amp`](https://github.com/helmedeiros/amp) Apple Music player — a terminal
CLI (`am`) that controls Music.app via AppleScript.

## What this topic does

- **`install.sh`** (run by `bin/dot`) `go install`s the `amp` binary and
  regenerates the zsh completion.
- **`_amp`** is the generated zsh completion. `zsh/fpath.zsh` adds every topic
  dir to `fpath`, so `compinit` autoloads it and `amp <Tab>` just works.

No `path.zsh` is needed: `amp` installs into `$GOPATH/bin`, which `go/path.zsh`
already puts on `PATH`.

## Usage

```sh
amp status            # what's playing (add --json for scripts)
amp play | pause | toggle | stop | next | prev
amp vol 60 | +10 | -10 | up | down
amp mute | unmute
amp shuffle [on|off]  # no arg toggles
amp repeat off|one|all
```
