# gcp-hcp-demo

Demonstration repository for creating and managing Hypershift hosted clusters on GCP.

## Purpose

Provides a simple, batteries-included demo of the GCP HCP platform that anyone can run.

## Principles

- **Simplicity above all** - Make it as easy as possible to get started
- **Bash scripts** - Simple, readable, no complex tooling required
- **Minimal dependencies** - Only require what's absolutely necessary (gcloud, gcphcp CLI)
- **Sensible defaults** - Works out-of-the-box without extensive configuration
- **Anyone can use it** - Clear instructions, interactive prompts when needed
- **Idempotent operations** - Safe to re-run scripts multiple times

## Design Goals

- Demonstrate the complete lifecycle of a hosted cluster
- Require minimal user input
- Be self-documenting through clear script names and prompts
- Fail fast with helpful error messages
- Keep it DRY with shared configuration
