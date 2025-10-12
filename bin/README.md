# Bin Scripts

This directory contains executable scripts that are added to your `$PATH` when using these dotfiles. These scripts provide various utilities to enhance your development workflow.

## Available Scripts

### General Utilities

| Script      | Description                                                                         |
| ----------- | ----------------------------------------------------------------------------------- |
| `headers`   | View HTTP headers from web requests without the clutter of response bodies.         |
| `res`       | Toggle between screen resolutions on macOS (supports Ventura, Sonoma, and Sequoia). |
| `search`    | Search for a string in a directory.                                                 |
| `todo`      | Create a simple TODO file in the current directory.                                 |
| `unzip-all` | Unzip all zip files in the current directory.                                       |
| `yt`        | Download a YouTube video as an MP4.                                                 |

### Git Utilities

| Script                    | Description                                                              |
| ------------------------- | ------------------------------------------------------------------------ |
| `git-all`                 | Run a git command on all repositories in the current directory.          |
| `git-amend`               | Amend the currently staged files to the latest commit.                   |
| `git-copy-branch-name`    | Copy the current branch name to the clipboard.                           |
| `git-credit`              | Add a user as an author to the latest commit.                            |
| `git-credit-all`          | Add multiple users as authors to the latest commit.                      |
| `git-delete-local-merged` | Delete all local branches that have been merged into the current branch. |
| `git-nuke`                | Delete a branch locally and on the remote.                               |
| `git-promote`             | Promote a local branch to a remote tracking branch.                      |
| `git-pull-requests`       | Open the pull requests page for the current repository.                  |
| `git-rank-contributors`   | Rank contributors by the number of commits.                              |
| `git-track`               | Track a remote branch.                                                   |
| `git-undo`                | Undo the last commit.                                                    |
| `git-unpushed`            | Show the diff of what hasn't been pushed yet.                            |
| `git-unpushed-stat`       | Show the diffstat of what hasn't been pushed yet.                        |
| `git-up`                  | Fetch and rebase all locally tracked branches.                           |
| `git-wtf`                 | Display the state of your repository in a readable format.               |
| `gitio`                   | Create a git.io short URL.                                               |

### System Utilities

| Script          | Description                                                                |
| --------------- | -------------------------------------------------------------------------- |
| `check-updates` | Check for updates to dotfiles, Homebrew packages, and npm global packages. |
| `dot`           | Set up environment, install dependencies, and configure macOS defaults.    |
| `e`             | Quick shortcut to open files in the editor.                                |
| `history-clean` | Securely remove specific entries from your shell history.                  |
| `set-defaults`  | Set macOS defaults.                                                        |

### Kubernetes Utilities

| Script       | Description                                |
| ------------ | ------------------------------------------ |
| `kube-setup` | Set up Kubernetes configuration and tools. |

### Cloud Utilities

| Script        | Description                            |
| ------------- | -------------------------------------- |
| `gh-packages` | List GitHub packages for a repository. |

## Detailed Documentation

### headers

A utility to view HTTP headers from web requests.

```
USAGE:
  headers [options] URL

OPTIONS:
  -X, --request METHOD   Specify the request method (GET, POST, etc.)
  -H, --header HEADER    Pass custom header(s) to server
  -d, --data DATA        Send data in the request body
  -i, --include          Include the request headers in the output
  -h, --help             Display this help message

EXAMPLES:
  headers https://example.com
  headers -X POST -H "Content-Type: application/json" -d '{"key":"value"}' https://api.example.com
  headers -i https://example.com
```

### res

A small command line script to change screen resolutions on macOS.

This script toggles between the default resolution and "More Space" resolution on macOS. It supports all recent macOS versions including Ventura, Sonoma, and Sequoia.

```
USAGE:
  res

NOTES:
  - No arguments needed, simply run the command to toggle resolution
  - Works with both System Preferences (older macOS) and System Settings (newer macOS)
  - Automatically detects your macOS version and uses the appropriate method
```

### check-updates

Check for updates to dotfiles, Homebrew packages, and npm global packages.

```
USAGE:
  check-updates

NOTES:
  - Checks if your dotfiles repository is behind the remote
  - Checks for outdated Homebrew packages
  - Checks for outdated npm global packages
  - Displays a summary of available updates
  - Updates the status indicator for your prompt
```

### history-clean

A utility to securely remove specific entries from your shell history without creating new history entries with sensitive information.

```
USAGE:
  history-clean <line_number> [line_number2 ...]  - Remove specific line numbers from history
  history-clean -p <pattern>                      - Remove all lines matching a pattern
  history-clean --last <n>                        - Remove the last n lines from history
  history-clean --autocomplete                    - Clear all autocompletion history
  history-clean --help                            - Show help message

EXAMPLES:
  history-clean 42                                - Remove line 42 from history
  history-clean 10 15 20                          - Remove lines 10, 15, and 20 from history
  history-clean -p "password"                     - Remove all lines containing "password"
  history-clean --last 5                          - Remove the last 5 commands from history
  history-clean --autocomplete                    - Clear all autocompletion history

NOTES:
  - Creates a backup of your history file before making changes
  - Cleans both command history and autocompletion/autosuggestions history
  - Changes take effect in new shell sessions
  - To apply changes to the current session, run: fc -R $HISTFILE
  - Particularly useful when you accidentally paste sensitive information like passwords
```

### git-delete-local-merged

Delete all local branches that have been merged into HEAD. This helps keep your repository clean by removing branches that are no longer needed.

```
USAGE:
  git-delete-local-merged

EXAMPLES:
  git-delete-local-merged                         - Delete all merged branches

NOTES:
  - Safely deletes only branches that have been fully merged into HEAD
  - Never deletes the current branch (the one you're on)
  - Never deletes the 'master' branch
  - Preserves any branches with unmerged commits
  - Handles branch names with special characters (e.g., feature/my-feature)
  - Works from anywhere within the repository (including subdirectories)
  - Safe to run - will not delete branches with unmerged work
  - If no branches need deletion, the command completes successfully without errors

WORKFLOW:
  A typical workflow would be:
  1. git checkout master
  2. git pull origin master
  3. git-delete-local-merged    # Cleans up old feature branches
```

## Adding New Scripts

When adding new scripts to this directory:

1. Make sure the script is executable (`chmod +x script-name`)
2. Add appropriate documentation at the top of the script
3. Update this README.md with information about your script
4. Consider adding a detailed usage section if the script has multiple options

Scripts in this directory are automatically added to your `$PATH` when using these dotfiles, making them available from anywhere in your terminal.
