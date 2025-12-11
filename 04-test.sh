#!/bin/bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# shellcheck disable=SC1091
source "$SCRIPT_DIR/setenv"

# Check for required parameters
if [ $# -lt 1 ]; then
    _gcp_hcp_error "Usage: $0 <cluster-name>"
    _gcp_hcp_error "Example: $0 my-cluster"
    exit 1
fi

CLUSTER_NAME="$1"
KUBECONFIG_FILE="${SCRIPT_DIR}/${CLUSTER_NAME}.kubeconfig"

_gcp_hcp_info "Step 4: Test Cluster with Whalesay Job"
_gcp_hcp_info "This script will deploy a test job to cluster '$CLUSTER_NAME'"
echo

# Check if kubeconfig exists
if [ ! -f "$KUBECONFIG_FILE" ]; then
    _gcp_hcp_error "Kubeconfig not found: $KUBECONFIG_FILE"
    _gcp_hcp_error "Run: $SCRIPT_DIR/03-kubeconfig.sh $CLUSTER_NAME"
    exit 1
fi

# Check if whalesay-job.yaml exists
if [ ! -f "$SCRIPT_DIR/whalesay-job.yaml" ]; then
    _gcp_hcp_error "whalesay-job.yaml not found in $SCRIPT_DIR"
    exit 1
fi

export KUBECONFIG="$KUBECONFIG_FILE"

_gcp_hcp_info "Applying whalesay job..."
oc apply -f "$SCRIPT_DIR/whalesay-job.yaml"

echo
_gcp_hcp_info "Waiting for job to complete (timeout: 5 minutes)..."

# Wait for job to complete
if ! oc wait --for=condition=complete job/whalesay --timeout=300s; then
    _gcp_hcp_error "Job failed or timed out!"
    oc describe job whalesay
    exit 1
fi

_gcp_hcp_info "Job completed successfully!"

echo
_gcp_hcp_info "Job logs:"
echo "---"
oc logs job/whalesay
echo "---"
echo

_gcp_hcp_info "Test completed successfully!"
