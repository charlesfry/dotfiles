#!/bin/bash

WHEREIS_OUT="$(whereis conda)"

# -------------------------
# Already installed?
# -------------------------
if [[ "$WHEREIS_OUT" != "conda:" ]]; then
  echo "✅ Conda already present (whereis): $WHEREIS_OUT"
  exit 0
fi

if ! command -v wget &>/dev/null; then
  sudo pacman -S --noconfirm wget
fi

wget -O Miniforge3.sh "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
bash Miniforge3.sh -b -p "${HOME}/miniforge3"
rm Miniforge3.sh
