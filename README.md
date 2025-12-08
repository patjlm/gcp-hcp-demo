# GCP HCP Demo

Quick demo to create a Hypershift hosted cluster on GCP.

## Prerequisites

- `gcloud` CLI ([install](https://cloud.google.com/sdk/docs/install))
- `pipx` or `pip` ([install pipx](https://pipxproject.github.io/pipx/installation/))
- `docker` or `podman`

## Quick Start

Run all steps in one go:

```bash
./ALL.sh
```

Or run step-by-step:

```bash
./00-init-project.sh      # Create GCP project and enable services
./01-setup-gcphcp-cli.sh  # Install gcphcp CLI and hypershift binary
./02-create-cluster.sh    # Create hosted cluster
```

## Customization

Create `setenv.local` to override defaults:

```bash
export PROJECT_ID=my-custom-project
export CLUSTER_NAME=my-cluster
export FOLDER_ID=123456789012
```

See `setenv.local.example` for all options.

## Cleanup

Delete the cluster:

```bash
./10-delete-cluster.sh
```
