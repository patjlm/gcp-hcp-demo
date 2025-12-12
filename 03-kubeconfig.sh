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

_gcp_hcp_info "Step 3: Generate Cluster Access Credentials"
_gcp_hcp_info "This script will generate a kubeconfig for cluster '$CLUSTER_NAME'"
echo

# Get cluster status to extract API URL
_gcp_hcp_info "Retrieving cluster API endpoint..."
API_URL=$(gcphcp --api-endpoint "$GCPHCP_API_ENDPOINT" --format json clusters status "$CLUSTER_NAME" --all | jq -r '.controller_status[0].conditions[] | select(.type == "APIServer") | .message')

if [ -z "$API_URL" ] || [ "$API_URL" == "null" ]; then
    _gcp_hcp_error "Could not retrieve API endpoint for cluster '$CLUSTER_NAME'"
    _gcp_hcp_error "Cluster may still be provisioning or does not exist"
    exit 1
fi

_gcp_hcp_info "Cluster API endpoint: $API_URL"
echo

_gcp_hcp_info "Creating kubeconfig at ${SCRIPT_DIR}/${CLUSTER_NAME}.kubeconfig"

KUBECONFIG_FILE="${SCRIPT_DIR}/${CLUSTER_NAME}.kubeconfig"

# Create kubeconfig with exec command that returns proper JSON format
cat > "$KUBECONFIG_FILE" <<EOF
apiVersion: v1
kind: Config
clusters:
- cluster:
    server: $API_URL
  name: $CLUSTER_NAME
contexts:
- context:
    cluster: $CLUSTER_NAME
    user: gcp-user
  name: ${CLUSTER_NAME}-context
current-context: ${CLUSTER_NAME}-context
users:
- name: gcp-user
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      command: bash
      args:
      - -c
      - |
        cat <<EOT
        {
          "apiVersion": "client.authentication.k8s.io/v1beta1",
          "kind": "ExecCredential",
          "status": {
            "token": "\$(gcloud auth print-identity-token)"
          }
        }
        EOT
      interactiveMode: Never
EOF

_gcp_hcp_info "Kubeconfig created successfully!"
echo
_gcp_hcp_info "You can now access the cluster with:"
echo "  export KUBECONFIG=${KUBECONFIG_FILE}"
echo "  oc get namespaces"
echo
_gcp_hcp_info "Or use it directly:"
echo "  oc --kubeconfig ${KUBECONFIG_FILE} get namespaces"
echo
_gcp_hcp_info "Alternative - using oc login:"
echo "  oc login --token=\"\$(gcloud auth print-identity-token)\" --server=$API_URL"
