# GitHub Configuration Template

This directory contains templates for GitHub-related configurations that should be stored in your private `.dot-secrets` repository.

## Usage

1. Copy the template to your `.dot-secrets` repository:

```bash
mkdir -p ~/.dot-secrets/github
cp ~/.dotfiles/templates/dot-secrets/github/packages.sh ~/.dot-secrets/github/
```

2. Edit the file with your actual GitHub token and organization information:

```bash
vim ~/.dot-secrets/github/packages.sh
```

3. Make the script executable:

```bash
chmod +x ~/.dot-secrets/github/packages.sh
```

## Template Structure

The `packages.sh` file contains environment variables for GitHub Packages access:

- `GH_PACKAGES_TOKEN`: Your GitHub Personal Access Token with packages:read and packages:delete permissions
- `ORG`: Your GitHub organization name (optional)
- `REPO`: Your GitHub repository name (optional)

## Using with GitHub Packages Scripts

Once configured, you can use the GitHub Packages scripts with your credentials:

```bash
# The script will automatically source your credentials from .dot-secrets
~/.dotfiles/github/gh-packages.sh list

# Or you can override specific values
ORG=different-org REPO=specific-repo ~/.dotfiles/github/gh-packages.sh list
```

## Notes

- GitHub Personal Access Tokens should be kept secure and never committed to public repositories
- Consider using a token with the minimum required permissions
- Regularly rotate your tokens for better security 