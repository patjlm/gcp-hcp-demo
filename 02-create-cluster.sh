#!/bin/bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# shellcheck disable=SC1091
source "$SCRIPT_DIR/setenv"

# Check for required CLUSTER_NAME parameter
if [ $# -eq 0 ]; then
    _gcp_hcp_error "Usage: $0 <cluster-name>"
    _gcp_hcp_error "Example: $0 my-cluster"
    exit 1
fi

CLUSTER_NAME="$1"

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
gcphcp clusters create \
    --project "$PROJECT_ID" --region "$GCP_HCP_REGION" \
    --endpoint-access PublicAndPrivate \
    --setup-infra \
    "$CLUSTER_NAME"

_gcp_hcp_info "Cluster creation initiated successfully!"

 watch "gcphcp clusters status $CLUSTER_NAME --all"
