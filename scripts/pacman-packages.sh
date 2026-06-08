#!/bin/bash

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"  # ../ from install/ to repo root

### GENERAL PACKAGE INSTALLATION ###

# List of packages to install
PACKAGES=(
    wget
    bitwarden
    pacman-contrib      # paccache — used by emergency-clean / disk notes
    ncdu                # interactive disk-usage hunting
    rsync               # docker-subvolume migration
    direnv              # per-directory env loading — hooked in .bashrc
)

echo "🔧 Installing packages..."

for pkg in "${PACKAGES[@]}"; do
    if pacman -Qi "$pkg" &>/dev/null; then
        echo "✅ $pkg is already installed"
    else
        echo "⬇️ Installing $pkg..."
        sudo pacman -S --noconfirm "$pkg"
    fi
done

echo
echo "✅ All packages installed."
