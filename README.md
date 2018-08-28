# helmedeiros dotfiles

## topical

If you're adding a new area to your forked dotfiles — say, "Java" — you can simply add a `java` directory and put files in there. Anything with an extension of `.zsh` will get automatically included into your shell. Anything with an extension of `.symlink` will get symlinked without extension into `$HOME` when you run `script/bootstrap`.

## components

There's a few special files in the hierarchy.

- **bin/**: Anything in `bin/` will get added to your `$PATH` and be made
  available everywhere.
- **Brewfile**: This is a list of applications for [Homebrew Cask](http://caskroom.io) to install
- **topic/\*.zsh**: Any files ending in `.zsh` get loaded into your
  environment.
- **topic/path.zsh**: Any file named `path.zsh` is loaded first and is
  expected to setup `$PATH` or similar.
- **topic/completion.zsh**: Any file named `completion.zsh` is loaded
  last and is expected to setup autocomplete.
- **topic/\*.symlink**: Any files ending in `*.symlink` get symlinked into
  your `$HOME`. This is so you can keep all of those versioned in your dotfiles
  but still keep those autoloaded files in your home directory. These get
  symlinked in when you run `script/bootstrap`.

## install

Run this:

```sh
git clone https://github.com/helmedeiros/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
script/bootstrap
bin/dot
```

This will symlink the appropriate files in `.dotfiles` to your home directory.
Everything is configured and tweaked within `~/.dotfiles`.

The main file you'll want to change right off the bat is `zsh/zshrc.symlink`,
which sets up a few paths that'll be different on your particular machine.

`dot` is a simple script that installs some dependencies, sets OS X
defaults, and so on. Tweak this script, and occasionally run `dot` from
time to time to keep your environment fresh and up-to-date.

## key mapping

Karabiner is a powerful utility for keyboard customization.

You can expect some keyboard changing after running this `dotfiles`.


### Vimium mode everywhere:

Press `Esc` to enter Vimium mode.

```
Manipulating tabs

K, gt	Go one tab right
J, gT	Go one tab left
t	Create new tab
x	Close current tab
X	Restore closed tab
g0	Go to the first tab
g$	Go to the last tab
```
```
Navigating

h/j/k/l	Arrow Keys
gg	Scroll to the top of the page
G	Scroll to the bottom of the page
f, <c-f>	Scroll a full page down
b, <c-b>	Scroll a full page up
<c-u>	Scroll 20 lines up
<c-d>	Scroll 20 lines down
r	Reload the page
/	Search
n	Cycle forward to the next find match
N	Cycle backward to the previous find match
u	Undo
<c-r>	Redo
i	Enter insert mode
```

## thanks

I forked [Zach Holman](http://github.com/holman)' excellent
[dotfiles](http://github.com/holman/dotfiles)
