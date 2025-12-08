#!/bin/bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

"$SCRIPT_DIR/00-init-project.sh"
"$SCRIPT_DIR/01-setup-gcphcp-cli.sh"
"$SCRIPT_DIR/02-create-cluster.sh"
