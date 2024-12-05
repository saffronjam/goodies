#!/bin/bash

# Validate input arguments
if [ "$#" -ne 5 ]; then
    echo "Usage: $0 <namespace> <secret-name> <docker-registry> <docker-username> <docker-password>"
    exit 1
fi

# Assign input arguments to variables
NAMESPACE=$1
SECRET_NAME=$2
DOCKER_REGISTRY=$3
DOCKER_USERNAME=$4
DOCKER_PASSWORD=$5

# Base64-encode the credentials
AUTH=$(echo -n "${DOCKER_USERNAME}:${DOCKER_PASSWORD}" | base64)

# Retrieve the existing secret, decode it, and parse it as JSON
SECRET=$(kubectl get secret "$SECRET_NAME" -n "$NAMESPACE" -o jsonpath='{.data.\.dockerconfigjson}' | base64 -d)

# Check if secret retrieval was successful
if [ -z "$SECRET" ]; then
    echo "Error: Secret $SECRET_NAME in namespace $NAMESPACE not found."
    exit 2
fi

# Append the new registry and credentials
UPDATED_SECRET=$(echo "$SECRET" | jq --arg registry "$DOCKER_REGISTRY" --arg auth "$AUTH" '
    .auths[$registry] = { "auth": $auth }
')

# Re-encode the updated secret and update it in Kubernetes
kubectl patch secret "$SECRET_NAME" -n "$NAMESPACE" --type='json' -p="[{\"op\": \"replace\", \"path\": \"/data/.dockerconfigjson\", \"value\": \"$(echo -n "$UPDATED_SECRET" | base64 -w 0)\"}]"

# Check if the patch was successful
if [ $? -eq 0 ]; then
    echo "Successfully updated Docker pull secret."
else
    echo "Failed to update Docker pull secret."
    exit 3
fi
