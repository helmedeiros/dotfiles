#!/bin/zsh
#
# Kubernetes configuration
#

# Source the company-specific configuration if it exists
if [ -f "$HOME/.dot-secrets/kubernetes/config.sh" ]; then
  source "$HOME/.dot-secrets/kubernetes/config.sh"
  
  # Set KUBECONFIG if the company configuration file exists and KUBE_CONFIG_FILENAME is defined
  if [ -n "$KUBE_CONFIG_FILENAME" ] && [ -f "$HOME/.kube/$KUBE_CONFIG_FILENAME" ]; then
    export KUBECONFIG="$HOME/.kube/$KUBE_CONFIG_FILENAME"
  fi
# Check for goeuro-debug.conf
elif [ -f "$HOME/.kube/goeuro-debug.conf" ]; then
  export KUBECONFIG="$HOME/.kube/goeuro-debug.conf"
# Fallback to a default name if the config doesn't exist
elif [ -f "$HOME/.kube/config" ]; then
  export KUBECONFIG="$HOME/.kube/config"
fi

# Don't try to load kubectl completion in non-interactive shells
# or if compdef isn't available (which means completion system isn't initialized)
if [[ $- == *i* ]] && command -v kubectl &> /dev/null && command -v compdef &> /dev/null; then
  # Add kubectl completion only in interactive shells
  source <(kubectl completion zsh 2>/dev/null)
fi 