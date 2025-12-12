#!/bin/bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# shellcheck disable=SC1091
source "$SCRIPT_DIR/setenv"

# Check for required PROJECT_ID parameter
if [ $# -eq 0 ]; then
    _gcp_hcp_error "Usage: $0 <project-id>"
    _gcp_hcp_error "Example: $0 my-gcp-project"
    exit 1
fi

PROJECT_ID="$1"

_gcp_hcp_info "Step 1: Setup gcphcp CLI and Hypershift"
_gcp_hcp_info "This script will install the gcphcp CLI tool and download the hypershift binary"
echo

# Setup gcphcp CLI
if ! command -v gcphcp &> /dev/null; then
    if command -v pipx &> /dev/null; then
        PIPX_CLI="pipx"
    elif command -v pip &> /dev/null; then
        PIPX_CLI="pip"
    else
        _gcp_hcp_error "pipx could not be found, please install pipx to continue"
        _gcp_hcp_error "to install: https://pipxproject.github.io/pipx/installation/"
        exit 1
    fi

    _gcp_hcp_info "gcphcp CLI could not be found, installing it with $PIPX_CLI..."
    $PIPX_CLI install gcphcp
fi

_gcp_hcp_info "gcphcp CLI is installed."

# Setup hypershift binary
if [ ! -f "$SCRIPT_DIR/hypershift" ]; then
    if [[ -n ${HYPERSHIFT_BINARY:-} ]]; then
        _gcp_hcp_info "Using HYPERSHIFT_BINARY from environment: $HYPERSHIFT_BINARY"
        cp "$HYPERSHIFT_BINARY" "$SCRIPT_DIR/hypershift"

    else
        if command -v podman &> /dev/null; then
            CONTAINER_CLI="podman"
        elif command -v docker &> /dev/null; then
            CONTAINER_CLI="docker"
        else
            _gcp_hcp_error "Neither docker nor podman could be found, please install one of them to continue"
            _gcp_hcp_error "to install docker: https://docs.docker.com/get-docker/"
            _gcp_hcp_error "to install podman: https://podman.io/getting-started/installation"
            exit 1
        fi

        : "${HYPERSHIFT_IMAGE:=quay.io/cveiga/hypershift:gcp-hcp-pilot-062b7763}"
        _gcp_hcp_info "Hypershift binary not found, downloading it from $HYPERSHIFT_IMAGE with $CONTAINER_CLI..."
        $CONTAINER_CLI run --rm --entrypoint cat "$HYPERSHIFT_IMAGE" /usr/bin/hypershift > "$SCRIPT_DIR/hypershift"
    fi

    chmod +x "$SCRIPT_DIR/hypershift"
fi

_gcp_hcp_info "Hypershift binary is set up."

_gcp_hcp_info "Configuring gcphcp CLI..."
gcphcp config set default_project "$PROJECT_ID"
# Not setting the API endpoint so we can run this script in parallel targeting multiple environments/regions
# We use `--api-endpoint "$GCPHCP_API_ENDPOINT"` everywhere instead
# gcphcp config set api_endpoint "${GCPHCP_API_ENDPOINT}"
gcphcp config set hypershift_binary "$SCRIPT_DIR/hypershift"
gcphcp config list

_gcp_hcp_info "CLI setup complete!"
