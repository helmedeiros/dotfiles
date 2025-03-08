# DBeaver Configuration Template

This directory contains templates for DBeaver database connection configurations that should be stored in your private `.dot-secrets` repository.

## Usage

1. Copy the template to your `.dot-secrets` repository:

```bash
mkdir -p ~/.dot-secrets/dbeaver
cp ~/.dotfiles/templates/dot-secrets/dbeaver/data-sources.json ~/.dot-secrets/dbeaver/
```

2. Edit the file with your actual database connection information:

```bash
vim ~/.dot-secrets/dbeaver/data-sources.json
```

3. Run the DBeaver installation script to apply your configuration:

```bash
~/.dotfiles/dbeaver/install.sh
```

## Template Structure

The `data-sources.json` file contains a template for modern DBeaver (v22+) configurations. It includes:

- A sample PostgreSQL connection
- Connection type definitions

You should replace the sample connection with your actual database connections, including proper hostnames, ports, and credentials.

## Notes

- This configuration works with DBeaver Community Edition v22 and newer
- The configuration will be applied to `~/Library/DBeaverData/workspace6/.metadata/.plugins/org.jkiss.dbeaver.core/data-sources.json`
- Your existing configuration will be backed up before applying the new one
- DBeaver must be run at least once before applying this configuration 