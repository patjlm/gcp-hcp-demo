# GCP HCP Demo

Quick demo to create a Hypershift hosted cluster on GCP.

## Prerequisites

- `gcloud` CLI ([install](https://cloud.google.com/sdk/docs/install))
- `pipx` or `pip` ([install pipx](https://pipxproject.github.io/pipx/installation/))
- `docker` or `podman`

## Quick Start

Run all steps in one go:

```bash
./ALL.sh <project-id> <cluster-name>
```

Example:
```bash
./ALL.sh my-gcp-project my-cluster
```

Or run step-by-step:

```bash
./00-init-project.sh my-gcp-project              # Create GCP project and enable services
./01-setup-gcphcp-cli.sh my-gcp-project          # Install gcphcp CLI and hypershift binary
./02-create-cluster.sh my-gcp-project my-cluster # Create hosted cluster
```

**Note:** Cluster name must be 15 characters or less.

## Customization

Create `setenv.local` to override defaults:

```bash
export FOLDER_ID=123456789012
export BILLING_ACCOUNT_ID=XXXXXX-XXXXXX-XXXXXX
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
