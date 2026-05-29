# Kubernetes

[`kubectl`](https://kubernetes.io/docs/tasks/tools/) configuration. `kubernetes-cli` is installed via the Brewfile.

## What `install.sh` does

Bootstraps a Kubernetes config from `~/.dot-secrets/kubernetes/config.sh` (private repo, kept out of dotfiles). Fails fast with a clear error if `kubectl` or `.dot-secrets` is missing, and offers a template at `templates/dot-secrets/kubernetes/` to start from.

## What gets loaded into your shell

- `path.zsh` — sources the kubernetes-secrets file (kubeconfig path, contexts, etc.) when present.
