#!/usr/bin/env bash

set -Eeuo pipefail

# Get repo root (directory of this script)
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS="$REPO_ROOT/scripts"

echo "🛠 Running master setup script from $REPO_ROOT"

# enable execution of scripts in scripts/
find "$REPO_ROOT/scripts" -type f -name "*.sh" -exec chmod +x {} \;

# Install packages
echo "📦 installing packages..."
"$SCRIPTS/pacman-packages.sh"

# Install Miniforge3
echo "🐍 installing Miniforge3..."
"$SCRIPTS/install-miniforge3.sh"

# Install Brave with GPU support
echo "🌐 installing Brave browser with GPU support..."
"$SCRIPTS/brave-with-gpu.sh"

# remove bloat
echo "🧹 removing bloatware..."
"$SCRIPTS/remove-bloat.sh"
echo

# Set up VPN configs.
echo "🔐 setting up VPN configs..."
"$SCRIPTS/vpn.sh"
echo

# Call copy_confs.sh
echo "📋 copying configuration files..."
"$SCRIPTS/copy-confs.sh"
echo

# Reload to apply changes. Do this after everything else.
echo "Reloading to apply all changes..."
"$SCRIPTS/reload.sh"

# Get themes
echo "🎨 installing themes..."
"$SCRIPTS/themes.sh"

# Post install security hardening
"$SCRIPTS/post-install-security.sh"

