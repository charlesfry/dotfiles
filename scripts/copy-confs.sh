#!/usr/bin/env bash
set -Eeuo pipefail

### CONFIG ###
CONFIGS=(alacritty bashrc hypr nvim shell waybar)
CONFIG_DIR="$HOME/.config"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"  # ../ from install/ to repo root
SRC_DIR="$ROOT_DIR/config"
echo "Copying config files from $SRC_DIR to $CONFIG_DIR"

TIMESTAMP="$(date +"%Y%m%d-%H%M%S")"
BACKUP_DIR="$ROOT_DIR/backup/.bak-$TIMESTAMP"

### SAFETY ###
trap 'echo "❌ Install failed on line $LINENO"; exit 1' ERR

echo "🔧 Dotfiles install starting..."
echo "📁 Repo: $SRC_DIR"
echo "📦 Backup dir: $BACKUP_DIR"
echo
mkdir -p "$BACKUP_DIR"


### SYMLINK SAFETY CHECK IN CASE THIS PC IS STRANGE ###
echo "🔍 Checking for existing symlinks..."
for cfg in "${CONFIGS[@]}"; do
  if [[ "$cfg" == "bashrc" ]]; then
    DEST="$HOME/.bashrc"
  else
    DEST="$CONFIG_DIR/$cfg"
  fi
  if [[ -L "$DEST" ]]; then
    echo "⛓‍💥  ERROR: $DEST is a symlink, which is not supported. Aborting install."
    exit 1
  fi
done
echo "  No symlink issues found."
echo


### MAIN LOOP ###
echo "Starting installation..."
for cfg in "${CONFIGS[@]}"; do
  if [[ "$cfg" == "bashrc" ]]; then
    SRC="$SRC_DIR/.bashrc"
    DEST="$HOME/.bashrc"
  else
    SRC="$SRC_DIR/$cfg"
    DEST="$CONFIG_DIR/"
  fi

  if [[ ! -e "$SRC" ]]; then
    echo "⚠️  Skipping $cfg (not found in repo)"
    continue
  fi

  if [[ -e "$DEST$cfg" && ! -L "$DEST$cfg" ]]; then
    echo "📦 Backing up $DEST"
    mv "$DEST$cfg" "$BACKUP_DIR/$cfg"
  fi

  echo "➡️  Installing $cfg by copying $SRC to $DEST"
  cp -r "$SRC" "$DEST"

  # Only make the copied .sh files executable
  while IFS= read -r -d '' file; do
    relative="${file#$SRC/}"
    chmod +x "$DEST/$relative"
  done < <(find "$SRC" -type f -name "*.sh" -print0)
done


### CUSTOM OVERRIDES ###
CUSTOMS_DIR="$ROOT_DIR/customs"
if [[ -d "$CUSTOMS_DIR" ]]; then
  while IFS= read -r -d '' file; do
    relative="${file#$CUSTOMS_DIR/}"
    dest="$CONFIG_DIR/$relative"
    mkdir -p "$(dirname "$dest")"
    echo "🖥️  Applying custom override: $relative"
    cp "$file" "$dest"
  done < <(find "$CUSTOMS_DIR" -type f ! -name "*.example" -print0)
fi


echo
echo "✅ Done."
echo "🕒 Backup saved at: $BACKUP_DIR"

