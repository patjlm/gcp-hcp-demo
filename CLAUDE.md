# gcp-hcp-demo

Demonstration repository for creating and managing Hypershift hosted clusters on GCP.

## Purpose

Provides a simple, batteries-included demo of the GCP HCP platform that anyone can run.

## Principles

- **Simplicity above all** - Make it as easy as possible to get started
- **Bash scripts** - Simple, readable, no complex tooling required
- **Minimal dependencies** - Only require what's absolutely necessary (gcloud, gcphcp CLI)
- **Explicit over implicit** - No magic, all parameters are explicit and visible
- **Sensible defaults** - Common configuration has reasonable defaults that can be overridden
- **Anyone can use it** - Clear instructions and helpful error messages
- **Idempotent operations** - Safe to re-run scripts multiple times
- **Reproducible** - Same inputs produce same results, no hidden state

## Design Goals

- Demonstrate the complete lifecycle of a hosted cluster
- Be self-documenting through clear script names and usage messages
- Fail fast with helpful error messages
- Keep it DRY with shared configuration
- No interactive prompts - fully scriptable and automatable
