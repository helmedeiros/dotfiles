# Cursor Configuration

This directory contains configuration files specific to Cursor, the AI-powered code editor.

## Contents

- `settings.json.symlink`: Cursor-specific settings file
- `extensions.txt`: List of recommended Cursor extensions
- `install.sh`: Script to install Cursor settings and extensions

## Installation

Run the install script to set up Cursor:

```bash
./install.sh
```

This will:
1. Install Cursor settings
2. Install Cursor extensions (if Cursor is installed)

## Cursor-Specific Settings

The Cursor settings include:

```json
"files.associations": {
  "*.bats": "shellscript",
  "*.zsh": "shellscript",
  "*.zsh-theme": "shellscript"
}
```

This ensures that `.bats` files (Bash Automated Testing System) are properly highlighted as shell scripts in Cursor.

Additionally, Cursor-specific settings include:

```json
"cursor.showStatusBarItemsInActivity": true,
"cursor.showCompletionLengthHint": true,
"cursor.showCompletionContribution": true
```

## Manual Installation

If you prefer to install manually:

1. Copy `settings.json.symlink` to `~/Library/Application Support/Cursor/User/settings.json`
2. Install extensions listed in `extensions.txt` using:
   ```
   cursor --install-extension EXTENSION_ID
   ``` 