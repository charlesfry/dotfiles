#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Check if Brave is already installed
if command -v brave-browser >/dev/null 2>&1 || command -v brave-wayland >/dev/null 2>&1; then
    echo "✅ Brave already installed, skipping."
    exit 0
fi


# -------------------------
# Brave installation
# -------------------------
curl -fsSLO https://dl.brave.com/install.sh
chmod +x install.sh
sudo ./install.sh
rm install.sh

# -------------------------
# GPU check
# -------------------------
if ! lspci | grep -E "VGA|3D" | grep -Ei "NVIDIA|AMD|Intel"; then
    echo "⚠️ No GPU detected — skipping Brave GPU setup."
    exit 0
fi

# -------------------------
# Wayland wrapper
# -------------------------
sudo mkdir -p /usr/local/bin
if [[ ! -f /usr/local/bin/brave-wayland ]]; then
    sudo cp "$ROOT_DIR/scripts/browser/brave-wayland" /usr/local/bin/brave-wayland
    sudo chmod +x /usr/local/bin/brave-wayland
fi

# -------------------------
# Desktop file
# -------------------------
mkdir -p "$HOME/.local/share/applications"
cp /usr/share/applications/brave-browser.desktop "$HOME/.local/share/applications/brave-wayland.desktop"

echo "✅ Brave installed with Wayland wrapper."
