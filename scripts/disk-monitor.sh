#!/usr/bin/env bash
# Install the disk-usage monitor: a systemd user timer that checks / every 4h
# and fires a critical desktop notification (with diagnostics) when usage >85%.
# Snapshot size in the alert needs root, so a tiny read-only helper is installed
# root-owned and whitelisted for passwordless sudo. See disk-monitor/ for the
# source files and ~/disk-space-fixes.md for the remediation playbook.
set -Eeuo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$REPO_ROOT/disk-monitor"

echo "💽 Installing disk-usage monitor..."

# 1. User-facing alert script.
install -D -m 755 "$SRC/disk-usage-alert" "$HOME/.local/bin/disk-usage-alert"

# 2. Remediation notes.
install -D -m 644 "$SRC/disk-space-fixes.md" "$HOME/disk-space-fixes.md"

# 3. systemd user timer (runs only while logged in — when notifications matter).
install -D -m 644 "$SRC/disk-usage-alert.service" "$HOME/.config/systemd/user/disk-usage-alert.service"
install -D -m 644 "$SRC/disk-usage-alert.timer"   "$HOME/.config/systemd/user/disk-usage-alert.timer"
if systemctl --user show-environment &>/dev/null; then
  systemctl --user daemon-reload
  systemctl --user enable --now disk-usage-alert.timer
  echo "  ✅ timer enabled (every 4h)."
else
  echo "  ⚠️  no user systemd session — enable later with: systemctl --user enable --now disk-usage-alert.timer"
fi

# 4. Privileged snapshot helper + sudoers whitelist + btrfs quota (needs root).
if sudo -v 2>/dev/null; then
  sudo install -D -m 755 -o root -g root "$SRC/disk-snapshot-usage" /usr/local/sbin/disk-snapshot-usage
  # Personalize the whitelist to the current user, then validate before trusting it.
  sed "s/^char /$USER /" "$SRC/disk-usage-alert.sudoers" \
    | sudo install -m 440 -o root -g root /dev/stdin /etc/sudoers.d/disk-usage-alert
  sudo visudo -cf /etc/sudoers.d/disk-usage-alert
  # Enable btrfs quota so snapshot exclusive (reclaimable) space can be reported.
  if findmnt -no FSTYPE / | grep -q btrfs; then
    sudo btrfs quota enable / 2>/dev/null || true
  fi
  echo "  ✅ snapshot helper + sudoers installed."
else
  echo "  ⚠️  no sudo — skipped helper/sudoers/quota; background alerts won't show snapshot size until installed."
fi

echo "  Done. Test with: diskcheck   (force an alert with: diskcheck 1)"
