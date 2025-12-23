#!/usr/bin/env bash

# Get repo root (directory of this script)
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS="$REPO_ROOT/scripts"

echo "🛠 Running master setup script from $REPO_ROOT"

# enable execution of scripts in scripts/
find "$REPO_ROOT/scripts" -type f -name "*.sh" -exec chmod +x {} \;

# setup bluetooth connections
echo "🔵 setting up bluetooth connections..."
"$SCRIPTS/setup_bluetooth.sh"
echo

# remove bloat
echo "🧹 removing bloatware..."
"$SCRIPTS/remove_bloat.sh"
echo

# Call copy_confs.sh
echo "📋 copying configuration files..."
"$SCRIPTS/copy_confs.sh"
echo

