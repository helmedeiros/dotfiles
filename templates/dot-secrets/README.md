# .dot-secrets Templates

This directory contains templates for configuration files that should be stored in your private `.dot-secrets` repository. These templates help you set up sensitive configurations without exposing actual credentials in your public dotfiles repository.

## Overview

The `.dot-secrets` repository is designed to store sensitive information such as:
- API keys and tokens
- Database connection details
- Company-specific configurations
- Private server information
- Personal credentials

## Getting Started

1. Create a private repository called `.dot-secrets` (or clone your existing one)
2. Copy the template files from this directory to your `.dot-secrets` repository
3. Update the files with your actual credentials and configuration
4. Clone your `.dot-secrets` repository to your home directory:

```bash
git clone git@github.com:yourusername/.dot-secrets.git ~/.dot-secrets
```

## Available Templates

This directory contains templates for the following tools:

- **DBeaver**: Database connection configurations
- **GitHub**: GitHub tokens and package configurations
- **Kubernetes**: Kubernetes cluster configurations
- **Robo3T**: MongoDB connection configurations

Each subdirectory contains its own README with specific instructions for that tool.

## Best Practices

- Never commit actual secrets or tokens to your public dotfiles repository
- Keep your `.dot-secrets` repository private
- Consider using a password manager or keychain for especially sensitive credentials
- Regularly rotate your credentials and update your `.dot-secrets` repository

## Setup Instructions

1. Create a private repository called `.dot-secrets` (or clone your existing one)
2. Copy the template files from this directory to your `.dot-secrets` repository
3. Update the files with your actual credentials and configuration
4. Clone your `.dot-secrets` repository to your home directory:

```bash
git clone git@github.com:yourusername/.dot-secrets.git ~/.dot-secrets
```

## Available Templates

### GitHub Packages

The `github/packages.sh` template contains configuration for the GitHub Packages cleanup script.

To use it:

1. Copy the template to your `.dot-secrets` repository:
   ```bash
   mkdir -p ~/.dot-secrets/github
   cp templates/dot-secrets/github/packages.sh ~/.dot-secrets/github/
   ```

2. Edit the file with your actual GitHub token, organization, and repository information:
   ```bash
   vim ~/.dot-secrets/github/packages.sh
   ```

3. Make sure the file is executable:
   ```bash
   chmod +x ~/.dot-secrets/github/packages.sh
   ```

4. Run the cleanup script:
   ```bash
   ./gh-packages.sh
   ```

## Security Notes

- Never commit actual secrets or tokens to your public dotfiles repository
- Keep your `.dot-secrets` repository private
- Consider using a password manager or keychain for especially sensitive credentials 