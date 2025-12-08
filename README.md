# GCP HCP Demo

Quick demo to create a Hypershift hosted cluster on GCP.

## Prerequisites

- `gcloud` CLI ([install](https://cloud.google.com/sdk/docs/install))
- `pipx` or `pip` ([install pipx](https://pipxproject.github.io/pipx/installation/))
- `docker` or `podman`

## Quick Start

Run all steps in one go:

```bash
./ALL.sh <cluster-name>
```

Example:
```bash
./ALL.sh my-cluster
```

Or run step-by-step:

```bash
./00-init-project.sh              # Create GCP project and enable services
./01-setup-gcphcp-cli.sh          # Install gcphcp CLI and hypershift binary
./02-create-cluster.sh my-cluster # Create hosted cluster
```

**Note:** Cluster name must be 15 characters or less.

## Customization

Create `setenv.local` to override defaults:

```bash
export PROJECT_ID=my-custom-project
export FOLDER_ID=123456789012
```

See `setenv.local.example` for all options.

## Cleanup

Delete the cluster:

```bash
./10-delete-cluster.sh <cluster-name>
```

Example:
```bash
./10-delete-cluster.sh my-cluster
```
