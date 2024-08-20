#!/bin/bash

# This script removes a context from ~/.kube/config given its name

# Check if the user provided a context name
if [ -z "$1" ]; then
  echo "Usage: $0 context_name_to_remove"
  exit 1
fi

# Paths
CONTEXT_NAME="$1"
DEFAULT_KUBECONFIG="$HOME/.kube/config"

# Ensure the default kubeconfig exists
if [ ! -f "$DEFAULT_KUBECONFIG" ]; then
  echo "Kubeconfig file not found at $DEFAULT_KUBECONFIG"
  exit 1
fi

# Remove the context
kubectl config delete-context "$CONTEXT_NAME"

# Optional: If desired, remove any related cluster and user entries
echo "Do you want to remove the associated cluster and user? [y/N]"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
  kubectl config unset "clusters.$CONTEXT_NAME"
  kubectl config unset "users.$CONTEXT_NAME"
  echo "Removed cluster and user associated with $CONTEXT_NAME"
fi

echo "Context $CONTEXT_NAME removed from $DEFAULT_KUBECONFIG"