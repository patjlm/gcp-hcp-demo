#!/bin/bash

# this script performs the required actions to be ready to work with GCP HCP

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# shellcheck disable=SC1091
source "$SCRIPT_DIR/setenv"

# ensure gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo "gcloud could not be found, please install the Google Cloud SDK"
    echo "to install: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# ensure we're logged in
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" &> /dev/null; then
    echo "no active gcloud account found, please login"
    gcloud auth login
fi

if gcloud projects describe "$PROJECT_ID" &> /dev/null; then
    echo "Project with ID $PROJECT_ID already exists. Are you sure you want to continue? (y/n)"
    read -r response
    if [[ "$response" != "y" ]]; then
        echo "Exiting."
        exit 0
    fi
else
    echo "Creating project with ID $PROJECT_ID in folder $FOLDER_ID..."
    gcloud projects create "$PROJECT_ID" \
        --folder="$FOLDER_ID" \
        --labels="app-code=osd-002,service-phase=dev,cost-center=732"
fi

echo "Linking billing account $BILLING_ACCOUNT_ID to project $PROJECT_ID..."
gcloud beta billing projects link "$PROJECT_ID" --billing-account="$BILLING_ACCOUNT_ID"

echo "Enabling required services for project $PROJECT_ID..."
gcloud services enable \
    cloudresourcemanager.googleapis.com \
    iam.googleapis.com \
    compute.googleapis.com \
    dns.googleapis.com \
    networkservices.googleapis.com \
    --project="$PROJECT_ID"
