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

_gcp_hcp_info "GCP HCP Demo - Complete Setup"
_gcp_hcp_info "This script will run all setup steps for project '$PROJECT_ID' and cluster '$CLUSTER_NAME'"
echo

"$SCRIPT_DIR/00-init-project.sh" "$PROJECT_ID"
echo
"$SCRIPT_DIR/01-setup-gcphcp-cli.sh" "$PROJECT_ID"
echo
"$SCRIPT_DIR/02-create-cluster.sh" "$PROJECT_ID" "$CLUSTER_NAME"

echo
_gcp_hcp_info "All steps completed successfully!"
