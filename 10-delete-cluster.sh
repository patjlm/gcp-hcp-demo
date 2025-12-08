#!/bin/bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# shellcheck disable=SC1091
source "$SCRIPT_DIR/setenv"

echo "Deleting cluster $CLUSTER_NAME..."
gcphcp clusters delete "$CLUSTER_NAME"

echo "Cluster $CLUSTER_NAME deleted successfully."
