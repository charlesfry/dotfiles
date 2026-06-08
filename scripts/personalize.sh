#!/usr/bin/env bash
set -Eeuo pipefail

# Apply Charles-specific personalization (git identity + work/school shell
# functions). This repo is personal, but the personal bits are gated so a
# generic install stays clean. Run after copy-confs.sh (which deploys ~/.bashrc,
# whose tail sources ~/.bashrc.personal).
#
# Interactive by default; set PERSONALIZE=yes|no to answer non-interactively.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Git identity (only applied for a Charles PC).
GIT_NAME="Charles Fry"
GIT_EMAIL="charlesmfry@gmail.com"

case "${PERSONALIZE:-}" in
  yes|y|Y) choice=y ;;
  no|n|N)  choice=n ;;
  *)
    echo
    read -rn1 -p "🧑 Make this a Charles PC (git identity + work shell functions)? [y/N] " choice </dev/tty
    echo
    ;;
esac

if [[ "$choice" != [yY] ]]; then
  echo "  Skipping personalization (generic install)."
  exit 0
fi

echo "🧑 Applying Charles personalization..."

# 1. Git identity.
git config --global user.name  "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"
echo "  ✅ git identity: $GIT_NAME <$GIT_EMAIL>"

# 2. Work/school shell functions (sourced from ~/.bashrc).
install -D -m 644 "$ROOT_DIR/personal/bashrc.personal" "$HOME/.bashrc.personal"
echo "  ✅ installed ~/.bashrc.personal"

echo "  Done."
