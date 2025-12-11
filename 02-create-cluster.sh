#!/bin/bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# shellcheck disable=SC1091
source "$SCRIPT_DIR/setenv"

# Check for required parameters
if [ $# -lt 2 ]; then
    _gcp_hcp_error "Usage: $0 <project-id> <cluster-name>"
    _gcp_hcp_error "Example: $0 my-gcp-project my-cluster"
    exit 1
fi

PROJECT_ID="$1"
CLUSTER_NAME="$2"

# Validate cluster name length (max 15 chars)
if [ ${#CLUSTER_NAME} -gt 15 ]; then
    _gcp_hcp_error "Cluster name '$CLUSTER_NAME' is too long (${#CLUSTER_NAME} chars)"
    _gcp_hcp_error "Maximum allowed length is 15 characters"
    exit 1
fi

_gcp_hcp_info "Step 2: Create Hosted Cluster"
_gcp_hcp_info "This script will create a Hypershift hosted cluster named '$CLUSTER_NAME' in region $GCP_HCP_REGION"
echo

_gcp_hcp_info "Creating cluster '$CLUSTER_NAME'..."
gcphcp --api-endpoint "$CLS_API_GATEWAY_URL" clusters create \
    --project "$PROJECT_ID" --region "$GCP_HCP_REGION" \
    --endpoint-access PublicAndPrivate \
    --setup-infra \
    --replicas=2 \
    "$CLUSTER_NAME"

_gcp_hcp_info "Cluster creation initiated successfully!"

watch "gcphcp --api-endpoint $CLS_API_GATEWAY_URL clusters status $CLUSTER_NAME --all"

# Wait until the API Endpoint is available
_gcp_hcp_info "Waiting for cluster API endpoint to become available..."
until API_URL=$(gcphcp --api-endpoint "$CLS_API_GATEWAY_URL" --format json clusters status "$CLUSTER_NAME" --all | jq -r '.controller_status[0].conditions[] | select(.type == "APIServer") | .message') && [ -n "$API_URL" ] && [ "$API_URL" != "null" ]; do
    pprintf "."
    sleep 5
done
echo

# Extract and display the API URL endpoint
_gcp_hcp_info "Extracting cluster API endpoint..."
API_URL=$(gcphcp --api-endpoint "$CLS_API_GATEWAY_URL" --format json clusters status "$CLUSTER_NAME" --all | jq -r '.controller_status[0].conditions[] | select(.type == "APIServer") | .message')

if [ -n "$API_URL" ] && [ "$API_URL" != "null" ]; then
    echo
    _gcp_hcp_info "Cluster API endpoint:"
    echo "  $API_URL"
    echo
    _gcp_hcp_info "Next step: Generate kubeconfig to access the cluster"
    echo "  $SCRIPT_DIR/03-login.sh $CLUSTER_NAME"
else
    _gcp_hcp_error "Could not retrieve API endpoint. Cluster may still be provisioning."
    exit 1
fi
