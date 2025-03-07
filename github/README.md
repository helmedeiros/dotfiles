# GitHub Utilities

This directory contains scripts for working with GitHub.

## Packages Cleanup Script

The `gh-packages.sh` script helps clean up old versions of npm packages in GitHub Packages.

### Configuration

The script looks for configuration in your `.dot-secrets` repository at:
```
~/.dot-secrets/github/packages.sh
```

See the templates directory for an example configuration file.

### Usage

```bash
# With configuration from .dot-secrets
./gh-packages.sh

# Or with manual configuration
GH_PACKAGES_TOKEN=your_token ORG=your_org REPO=your_repo ./gh-packages.sh
```

### What it does

1. Fetches the number of versions for a specific npm package
2. Identifies the oldest versions of the package
3. Deletes older versions, keeping only a specified number of recent versions (default is 20)

This helps prevent accumulating too many versions of packages in your GitHub Packages registry. 