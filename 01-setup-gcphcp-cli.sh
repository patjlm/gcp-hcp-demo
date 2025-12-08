#!/bin/bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# shellcheck disable=SC1091
source "$SCRIPT_DIR/setenv"

# Setup gcphcp CLI
if ! command -v gcphcp &> /dev/null; then
    if command -v pipx &> /dev/null; then
        PIPX_CLI="pipx"
    elif command -v pip &> /dev/null; then
        PIPX_CLI="pip"
    else
        echo "pipx could not be found, please install pipx to continue"
        echo "to install: https://pipxproject.github.io/pipx/installation/"
        exit 1
    fi

    echo "gcphcp CLI could not be found, installing it with $PIPX_CLI..."
    $PIPX_CLI install gcphcp
fi

echo "gcphcp CLI is installed."

# Setup hypershift binary
if [ ! -f "$SCRIPT_DIR/hypershift" ]; then
    if [[ -n ${HYPERSHIFT_BINARY:-} ]]; then
        echo "Using HYPERSHIFT_BINARY from environment: $HYPERSHIFT_BINARY"
        cp "$HYPERSHIFT_BINARY" "$SCRIPT_DIR/hypershift"

    else
        if command -v podman &> /dev/null; then
            CONTAINER_CLI="podman"
        elif command -v docker &> /dev/null; then
            CONTAINER_CLI="docker"
        else
            echo "Neither docker nor podman could be found, please install one of them to continue"
            echo "to install docker: https://docs.docker.com/get-docker/"
            echo "to install podman: https://podman.io/getting-started/installation"
            exit 1
        fi

        : "${HYPERSHIFT_IMAGE:=quay.io/cveiga/hypershift:gcp-hcp-pilot-57881086}"
        echo "Hypershift binary not found, downloading it from $HYPERSHIFT_IMAGE with $CONTAINER_CLI..."
        $CONTAINER_CLI run --rm --entrypoint cat "$HYPERSHIFT_IMAGE" /usr/bin/hypershift > "$SCRIPT_DIR/hypershift"
    fi

    chmod +x "$SCRIPT_DIR/hypershift"
fi

echo "Hypershift binary is set up."

echo "Configuring gcphcp CLI..."
gcphcp config set default_project "$PROJECT_ID"
# setting the integration us-central1 endpoint
gcphcp config set api_endpoint https://cls-backend-gateway-9gpamuy7.uc.gateway.dev
gcphcp config set hypershift_binary "$SCRIPT_DIR/hypershift"
gcphcp config list
