#!/bin/zsh
#
# Kubernetes configuration
#

# Source the per-employer kubernetes configuration from .dot-secrets if
# present. KUBE_CONFIG_FILENAME lives in ~/.dot-secrets/kubernetes/config.sh
# (see templates/dot-secrets/kubernetes/config.sh for the shape) so the
# specific kubeconfig name never appears in this public repo.
if [ -f "$HOME/.dot-secrets/kubernetes/config.sh" ]; then
  source "$HOME/.dot-secrets/kubernetes/config.sh"

  if [ -n "$KUBE_CONFIG_FILENAME" ] && [ -f "$HOME/.kube/$KUBE_CONFIG_FILENAME" ]; then
    export KUBECONFIG="$HOME/.kube/$KUBE_CONFIG_FILENAME"
  fi
# Fallback to the default ~/.kube/config when no .dot-secrets override exists.
elif [ -f "$HOME/.kube/config" ]; then
  export KUBECONFIG="$HOME/.kube/config"
fi

# Don't try to load kubectl completion in non-interactive shells
# or if compdef isn't available (which means completion system isn't initialized)
if [[ $- == *i* ]] && command -v kubectl &> /dev/null && command -v compdef &> /dev/null; then
  # Add kubectl completion only in interactive shells
  source <(kubectl completion zsh 2>/dev/null)
fi
