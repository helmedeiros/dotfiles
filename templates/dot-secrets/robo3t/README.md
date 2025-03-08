# Robo3T Configuration Template

This directory contains templates for Robo3T (MongoDB client) configurations that should be stored in your private `.dot-secrets` repository.

## Usage

1. Copy the template to your `.dot-secrets` repository:

```bash
mkdir -p ~/.dot-secrets/robo3t
cp ~/.dotfiles/templates/dot-secrets/robo3t/robo3t.json ~/.dot-secrets/robo3t/
```

2. Edit the file with your actual MongoDB connection information:

```bash
vim ~/.dot-secrets/robo3t/robo3t.json
```

3. Run the Robo3T installation script to apply your configuration:

```bash
~/.dotfiles/robo3t/install.sh
```

## Template Structure

The `robo3t.json` file contains connection configurations for MongoDB databases:

- Connection names and aliases
- MongoDB server addresses and ports
- Authentication credentials (if needed)
- SSH tunnel configurations (if needed)
- Database preferences and settings

## Notes

- The Robo3T installation script will back up any existing configuration before applying the new one
- You may need to run Robo3T at least once to create the initial configuration directory
- The script will not automatically open Robo3T after configuration
- Connection credentials are stored in this file, so keep your `.dot-secrets` repository private 