#!/usr/bin/env bash
# Make /var/lib/docker its own btrfs subvolume so docker images/layers are
# EXCLUDED from snapper snapshots (btrfs snapshots are not recursive). Without
# this, deleting docker images frees nothing while old snapshots still pin them
# — which is exactly how this machine filled to 95% once.
#
# Idempotent and safe: skips if root isn't btrfs or it's already a subvolume.
# Migrates existing data via a backup copy, removed only after docker verifies.
set -Eeuo pipefail

DOCKER_DIR=/var/lib/docker

# Only meaningful on btrfs.
if ! findmnt -no FSTYPE / | grep -q btrfs; then
  echo "🐳 / is not btrfs — skipping docker subvolume setup."
  exit 0
fi

# Already a subvolume? Nothing to do.
if sudo btrfs subvolume show "$DOCKER_DIR" &>/dev/null; then
  echo "🐳 $DOCKER_DIR is already a btrfs subvolume — nothing to do."
  exit 0
fi

echo "🐳 Converting $DOCKER_DIR to a dedicated btrfs subvolume..."
WAS_RUNNING=0
if systemctl is-active --quiet docker; then WAS_RUNNING=1; fi
sudo systemctl stop docker.service docker.socket 2>/dev/null || true

if [[ -d "$DOCKER_DIR" ]]; then
  sudo mv "$DOCKER_DIR" "${DOCKER_DIR}.old"
fi
sudo btrfs subvolume create "$DOCKER_DIR"
sudo chattr +C "$DOCKER_DIR"          # disable copy-on-write (best set while empty)
if [[ -d "${DOCKER_DIR}.old" ]]; then
  sudo rsync -aHAX "${DOCKER_DIR}.old/" "$DOCKER_DIR/"
fi

# Restart docker if it had been running, and verify before discarding the backup.
if [[ "$WAS_RUNNING" -eq 1 ]]; then
  sudo systemctl start docker
  if docker info &>/dev/null; then
    [[ -d "${DOCKER_DIR}.old" ]] && sudo rm -rf "${DOCKER_DIR}.old"
    echo "  ✅ docker healthy on new subvolume; backup removed."
  else
    echo "  ⚠️  docker did not come back cleanly. Backup kept at ${DOCKER_DIR}.old — investigate before deleting."
  fi
else
  [[ -d "${DOCKER_DIR}.old" ]] && sudo rm -rf "${DOCKER_DIR}.old"
  echo "  ✅ subvolume created. (docker was not running)"
fi
