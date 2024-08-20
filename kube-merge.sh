#!/bin/bash

# This script merges a given kubeconfig into the default ~/.kube/config

# Check if the user provided a kubeconfig file to merge
if [ -z "$1" ]; then
  echo "Usage: $0 path_to_kubeconfig_to_merge"
  exit 1
fi

# Paths
KUBECONFIG_TO_MERGE="$1"
DEFAULT_KUBECONFIG="$HOME/.kube/config"

# Ensure the default kubeconfig exists, if not create it
mkdir -p "$(dirname "$DEFAULT_KUBECONFIG")"
touch "$DEFAULT_KUBECONFIG"

# Temporarily set KUBECONFIG to include both files
export KUBECONFIG="$DEFAULT_KUBECONFIG:$KUBECONFIG_TO_MERGE"

# Merge and save back to the default kubeconfig
kubectl config view --flatten > /tmp/merged_kubeconfig
mv /tmp/merged_kubeconfig "$DEFAULT_KUBECONFIG"

echo "Successfully merged $KUBECONFIG_TO_MERGE into $DEFAULT_KUBECONFIG"