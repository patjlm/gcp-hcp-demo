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

_gcp_hcp_info "Delete Hosted Cluster"
_gcp_hcp_info "This script will delete the cluster '$CLUSTER_NAME'"
echo

_gcp_hcp_info "Deleting cluster $CLUSTER_NAME..."
gcphcp clusters delete "$CLUSTER_NAME"

_gcp_hcp_info "Cluster $CLUSTER_NAME deleted successfully."

# TODO: delete cluster infra & iam
