#!/usr/bin/env bash
set -Eeuo pipefail

# Get repo root (directory of this script)
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🛠 Running master make script from $REPO_ROOT"

# enable execution of scripts in scripts/
chmod +x "$REPO_ROOT/scripts/"*.sh

# Call copy_confs.sh
"$REPO_ROOT/scripts/copy_confs.sh"

# Add other tasks here later
# "$REPO_ROOT/scripts/another_task.sh"
