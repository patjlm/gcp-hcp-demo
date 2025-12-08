#!/bin/bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# shellcheck disable=SC1091
source "$SCRIPT_DIR/setenv"

gcphcp clusters create \
    --project "$PROJECT_ID" --region "$GCP_HCP_REGION" \
    --endpoint-access PublicAndPrivate \
    --setup-infra \
    "$CLUSTER_NAME"
