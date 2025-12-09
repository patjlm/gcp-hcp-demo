#!/bin/bash

# this script performs the required actions to be ready to work with GCP HCP

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

_gcp_hcp_info "Step 0: Initialize GCP Project"
_gcp_hcp_info "This script will create or verify GCP project '$PROJECT_ID', link billing, and enable required APIs"
echo

# ensure gcloud is installed
if ! command -v gcloud &> /dev/null; then
    _gcp_hcp_error "gcloud could not be found, please install the Google Cloud SDK"
    _gcp_hcp_error "to install: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# ensure we're logged in
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" &> /dev/null; then
    _gcp_hcp_info "No active gcloud account found, please login"
    gcloud auth login
fi

if gcloud projects describe "$PROJECT_ID" &> /dev/null; then
    _gcp_hcp_info "Project with ID $PROJECT_ID already exists. Are you sure you want to continue? (y/n)"
    read -r response
    if [[ "$response" != "y" ]]; then
        _gcp_hcp_info "Exiting."
        exit 0
    fi
else
    _gcp_hcp_info "Creating project with ID $PROJECT_ID in folder $FOLDER_ID..."
    gcloud projects create "$PROJECT_ID" \
        --folder="$FOLDER_ID" \
        --labels="app-code=osd-002,service-phase=dev,cost-center=732"
fi

_gcp_hcp_info "Linking billing account $BILLING_ACCOUNT_ID to project $PROJECT_ID..."
gcloud beta billing projects link "$PROJECT_ID" --billing-account="$BILLING_ACCOUNT_ID"

_gcp_hcp_info "Enabling required services for project $PROJECT_ID..."
gcloud services enable \
    cloudresourcemanager.googleapis.com \
    iam.googleapis.com \
    compute.googleapis.com \
    dns.googleapis.com \
    networkservices.googleapis.com \
    --project="$PROJECT_ID"

_gcp_hcp_info "Project initialization complete!"
