#!/usr/bin/env bash
set -Eeuo pipefail

### CONFIG ###
CONFIGS=(bashrc hypr nvim shell waybar)
CONFIG_DIR="$HOME/.config"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

TIMESTAMP="$(date +"%Y%m%d-%H%M%S")"
BACKUP_DIR="$REPO_DIR/backup/.bak-$TIMESTAMP"

### SAFETY ###
trap 'echo "❌ Install failed on line $LINENO"; exit 1' ERR

echo "🔧 Dotfiles install starting..."
echo "📁 Repo: $REPO_DIR"
echo "📦 Backup dir: $BACKUP_DIR"
echo

mkdir -p "$BACKUP_DIR"


### SYMLINK SAFETY CHECK ###
echo "🔍 Checking for existing symlinks..."
for cfg in "${CONFIGS[@]}"; do
  if [[ "$cfg" == "bashrc" ]]; then
    DEST="$HOME/.bashrc"
  else
    DEST="$CONFIG_DIR/$cfg"
  fi
  if [[ -L "$DEST" ]]; then
    echo "⛓‍💥 ERROR: $DEST is a symlink, which is not supported. Aborting install."
    exit 1
  fi
done


### MAIN LOOP ###
echo "Starting installation..."
for cfg in "${CONFIGS[@]}"; do
  if [[ "$cfg" == "bashrc" ]]; then
    SRC="$REPO_DIR/.bashrc"
    DEST="$HOME/.bashrc"
  else
    SRC="$REPO_DIR/$cfg"
    DEST="$CONFIG_DIR/$cfg"
  fi

  if [[ ! -e "$SRC" ]]; then
    echo "⚠️  Skipping $cfg (not found in repo)"
    continue
  fi

  if [[ -e "$DEST" && ! -L "$DEST" ]]; then
    echo "📦 Backing up $DEST"
    mv "$DEST" "$BACKUP_DIR/"
  fi

  echo "➡️  Installing $cfg"
  cp -r "$SRC" "$DEST"

  # Only make the copied .sh files executable
  while IFS= read -r -d '' file; do
    relative="${file#$SRC/}"
    chmod +x "$DEST/$relative"
  done < <(find "$SRC" -type f -name "*.sh" -print0)
done

### RELOAD PROCESSES ###
pkill waybar || true
nohup waybar >/dev/null 2>&1 &
hyprctl reload
source $HOME/.bashrc


echo
echo "✅ Done."
echo "🕒 Backup saved at: $BACKUP_DIR"

