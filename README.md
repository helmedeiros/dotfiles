# helmedeiros dotfiles

A collection of customized dotfiles to enhance your development environment on macOS.

## Overview

These dotfiles provide a comprehensive setup for developers, including:

- Custom terminal configuration with Solarized Dark theme
- Zsh shell with useful aliases and functions
- Kubernetes tools and configuration
- Homebrew package management
- Karabiner keyboard customization
- Vim-like navigation across applications
- Automatic update checking
- And much more!

## Structure

If you're adding a new area to your forked dotfiles — say, "Java" — you can simply add a `java` directory and put files in there. Anything with an extension of `.zsh` will get automatically included into your shell. Anything with an extension of `.symlink` will get symlinked without extension into `$HOME` when you run `script/bootstrap`.

### Key Components

There's a few special files in the hierarchy:

- **bin/**: Anything in `bin/` will get added to your `$PATH` and be made available everywhere.
- **Brewfile**: This is a list of applications for [Homebrew](https://brew.sh) to install.
- **topic/\*.zsh**: Any files ending in `.zsh` get loaded into your environment.
- **topic/path.zsh**: Any file named `path.zsh` is loaded first and is expected to setup `$PATH` or similar.
- **topic/completion.zsh**: Any file named `completion.zsh` is loaded last and is expected to setup autocomplete.
- **topic/\*.symlink**: Any files ending in `*.symlink` get symlinked into your `$HOME`. This is so you can keep all of those versioned in your dotfiles but still keep those autoloaded files in your home directory. These get symlinked in when you run `script/bootstrap`.
- **templates/**: Contains templates for files that should be stored in separate private repositories, such as `.dot-secrets`. These templates help you set up sensitive configurations without exposing actual credentials.
- **functions/**: Contains useful shell functions like `kubelog` for enhanced Kubernetes log viewing.

## Installation

Run this:

```sh
git clone https://github.com/helmedeiros/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
script/bootstrap
bin/dot
```

This will:
1. Clone the repository to your home directory
2. Symlink the appropriate files to your home directory
3. Install dependencies via Homebrew
4. Set up macOS defaults
5. Configure your shell environment

The main file you'll want to change right off the bat is `zsh/zshrc.symlink`, which sets up a few paths that'll be different on your particular machine.

### Keeping Up to Date

`dot` is a simple script that installs some dependencies, sets macOS defaults, and so on. Tweak this script, and occasionally run `dot` from time to time to keep your environment fresh and up-to-date:

```sh
bin/dot
```

### Automatic Updates

These dotfiles include an automatic update checker that runs once per day when you open a new shell. It will:

- Check if your local dotfiles are behind the remote repository
- Notify you when updates are available
- Provide a summary of changes
- Offer to update automatically

You can also manually check for updates at any time by running:

```sh
dotfiles-update-check
```

This helps ensure your development environment stays current with the latest improvements without requiring manual checks.

## Features

### Kubernetes Tools

The dotfiles include enhanced Kubernetes tools:
- `kubelog`: A powerful function for viewing and filtering Kubernetes pod logs
- VPN-aware configuration that gracefully handles connectivity issues
- Automatic context switching

### Terminal Configuration

- Solarized Dark theme for Terminal.app
- Custom prompt with git status information
- Syntax highlighting for commands

### Keyboard Customization

Karabiner is a powerful utility for keyboard customization. You can expect some keyboard changing after running this `dotfiles`.

#### Vimium Mode Everywhere:

Press `Esc` to enter Vimium mode.

##### Manipulating Tabs
```
K, gt   Go one tab right
J, gT   Go one tab left
t       Create new tab
x       Close current tab
X       Restore closed tab
g0      Go to the first tab
g$      Go to the last tab
```

##### Navigating
```
h/j/k/l Arrow Keys
gg      Scroll to the top of the page
G       Scroll to the bottom of the page
f, <c-f> Scroll a full page down
b, <c-b> Scroll a full page up
<c-u>   Scroll 20 lines up
<c-d>   Scroll 20 lines down
r       Reload the page
/       Search
n       Cycle forward to the next find match
N       Cycle backward to the previous find match
u       Undo
<c-r>   Redo
i       Enter insert mode
```

## Private Configuration

For sensitive information like API keys and company-specific configurations, create a `.dot-secrets` repository in your home directory. Templates for this repository can be found in the `templates/` directory.

## Customization

Feel free to fork this repository and customize it to your needs. The modular structure makes it easy to add, remove, or modify components without breaking the entire system.

## Acknowledgements

I forked [Zach Holman](http://github.com/holman)'s excellent [dotfiles](http://github.com/holman/dotfiles) and built upon his solid foundation.
