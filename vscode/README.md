# VSCode Configuration

This directory contains configuration files for Visual Studio Code.

## Contents

- `settings.json.symlink`: VSCode settings file
- `extensions.txt`: List of recommended VSCode extensions
- `install.sh`: Script to install settings and extensions

## Installation

Run the install script to set up VSCode:

```bash
./install.sh
```

This will:
1. Install VSCode settings
2. Install VSCode extensions (if VSCode is installed)

## File Associations

The settings include file associations for various file types:

```json
"files.associations": {
  "*.bats": "shellscript",
  "*.zsh": "shellscript",
  "*.zsh-theme": "shellscript"
}
```

This ensures that `.bats` files (Bash Automated Testing System) are properly highlighted as shell scripts in VSCode.

## BATS Testing Support

The configuration includes support for BATS testing framework:

- The `jetmartin.bats` extension provides syntax highlighting and snippets for BATS files
- ShellCheck integration for BATS files is enabled
- Test runner shows command line output for better debugging

## Manual Installation

If you prefer to install manually:

1. Copy `settings.json.symlink` to `~/Library/Application Support/Code/User/settings.json`
2. Install extensions listed in `extensions.txt` using:
   ```
   code --install-extension EXTENSION_ID
   ``` 