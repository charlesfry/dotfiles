# disk-monitor

Source files for the disk-usage monitoring + remediation setup. Installed by
`scripts/disk-monitor.sh` (run automatically from `setup.sh`).

## What it does

A systemd **user** timer checks `/` every 4h and, when usage exceeds 85%, fires
a critical desktop notification whose body diagnoses the likely culprits
(docker totals, snapshot reclaimable size, pacman cache, journal, biggest
`$HOME` dirs) so you know what to fix from the alert alone.

## Files

| File | Installed to | Purpose |
|------|--------------|---------|
| `disk-usage-alert` | `~/.local/bin/` | Cheap `df` check; on >85%, gathers diagnostics and notifies. |
| `disk-usage-alert.service` / `.timer` | `~/.config/systemd/user/` | Runs the check every 4h while logged in. |
| `disk-snapshot-usage` | `/usr/local/sbin/` (root-owned) | Read-only: sums btrfs snapshot exclusive (reclaimable) space. |
| `disk-usage-alert.sudoers` | `/etc/sudoers.d/disk-usage-alert` | Passwordless sudo for **only** the helper above. |
| `disk-space-fixes.md` | `~/disk-space-fixes.md` | Full remediation playbook. |

## Companion pieces (elsewhere in the repo)

- `config/.bashrc` — `diskcheck` (run the check on demand) and `emergency-clean`
  (reclaim space across docker/conda/cache/journal/snapshots), plus the
  "break glass" reference block.
- `scripts/docker-subvolume.sh` — makes `/var/lib/docker` its own btrfs
  subvolume so docker layers are excluded from snapshots (prevents the
  "deleted images still pinned by old snapshots" trap).

## Requirements

`notify-send` (libnotify), `paplay` (libpulse), `numfmt` (coreutils), and btrfs
quota enabled (`sudo btrfs quota enable /`) for snapshot size reporting. The
installer handles quota; packages come from `scripts/pacman-packages.sh`.
