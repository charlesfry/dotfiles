#!/usr/bin/env bash
# Set up the Python-side dependencies for the Neovim data-science stack
# (molten / jupytext). The Neovim config (config/nvim/lua/plugins/jupyter.lua +
# options.lua) is conda-independent: it uses a dedicated provider venv at
# ~/.venvs/neovim so it never collides with whatever conda env is active.
#
# Best-effort: this never aborts the master setup. Idempotent.
set -uo pipefail

VENV="$HOME/.venvs/neovim"

echo "🧠 Setting up Neovim Python host at $VENV ..."

if ! command -v python3 >/dev/null 2>&1; then
  echo "  ⚠️  python3 not found — skipping. Install python, then re-run this script."
  exit 0
fi

# 1. Dedicated provider venv (pynvim + jupyter_client power molten; jupytext
#    opens .ipynb; cairosvg/pillow let molten rasterize SVG/plot output).
if [[ ! -x "$VENV/bin/python" ]]; then
  python3 -m venv "$VENV" || { echo "  ⚠️  venv creation failed — skipping."; exit 0; }
fi
"$VENV/bin/python" -m pip install --quiet --upgrade pip
"$VENV/bin/python" -m pip install --quiet --upgrade \
  pynvim jupyter_client jupytext cairosvg pillow nbformat \
  && echo "  ✅ provider venv ready (pynvim, jupyter_client, jupytext, cairosvg)." \
  || echo "  ⚠️  some pip installs failed — molten/jupytext may be limited."

# 2. Make the `jupytext` CLI reachable from a normal shell (the plugin shells
#    out to it). Symlink into ~/.local/bin (already on PATH via .bashrc).
if [[ -x "$VENV/bin/jupytext" ]]; then
  install -d "$HOME/.local/bin"
  ln -sf "$VENV/bin/jupytext" "$HOME/.local/bin/jupytext"
  echo "  ✅ linked jupytext into ~/.local/bin"
fi

cat <<'EOF'

  NEXT STEPS (manual — they depend on your conda envs):
  • Register each conda env you want as a Jupyter kernel so MoltenInit can pick it:
        conda activate ds-ml-platform
        pip install ipykernel
        python -m ipykernel install --user --name ds-ml-platform
    (repeat per env: mmm, darts, ...)
  • In Neovim: open a .py/.ipynb, run  :MoltenInit  and choose the kernel.
  • Inline plots render only in kitty/ghostty (not alacritty). See config/nvim/README.md.
EOF
echo "  Done."
