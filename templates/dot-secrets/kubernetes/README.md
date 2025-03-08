# Kubernetes Configuration Template

This directory contains templates for Kubernetes-related configurations that should be stored in your private `.dot-secrets` repository.

## Usage

1. Copy the template to your `.dot-secrets` repository:

```bash
mkdir -p ~/.dot-secrets/kubernetes
cp ~/.dotfiles/templates/dot-secrets/kubernetes/config.sh ~/.dot-secrets/kubernetes/
```

2. Edit the file with your actual Kubernetes configuration information:

```bash
vim ~/.dot-secrets/kubernetes/config.sh
```

3. Make the script executable:

```bash
chmod +x ~/.dot-secrets/kubernetes/config.sh
```

4. Run the Kubernetes installation script to apply your configuration:

```bash
~/.dotfiles/kubernetes/install.sh
```

## Template Structure

The `config.sh` file contains environment variables for Kubernetes configuration:

- `KUBE_CONFIG_URL`: URL to download your Kubernetes configuration file
- `KUBE_CONFIG_FILENAME`: Filename to save the Kubernetes configuration as
- `DEFAULT_CONTEXT`: Default Kubernetes context to use

## Notes

- The Kubernetes installation script will check for VPN connectivity before attempting to download configurations
- If you're not connected to your company VPN, the script will gracefully skip the configuration
- The script will set up the KUBECONFIG environment variable in your shell profile
- You can use the `kubelog` function to view and filter logs from Kubernetes pods 