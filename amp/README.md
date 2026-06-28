# amp

The [`amp`](https://github.com/helmedeiros/amp) Apple Music player — a terminal
CLI (`am`) that controls Music.app via AppleScript.

## What this topic does

- **`install.sh`** (run by `bin/dot`) `go install`s the `am` binary and
  regenerates the zsh completion.
- **`_am`** is the generated zsh completion. `zsh/fpath.zsh` adds every topic
  dir to `fpath`, so `compinit` autoloads it and `am <Tab>` just works.

No `path.zsh` is needed: `am` installs into `$GOPATH/bin`, which `go/path.zsh`
already puts on `PATH`.

## Usage

```sh
am status            # what's playing (add --json for scripts)
am play | pause | toggle | stop | next | prev
am vol 60 | +10 | -10 | up | down
am mute | unmute
am shuffle [on|off]  # no arg toggles
am repeat off|one|all
```
