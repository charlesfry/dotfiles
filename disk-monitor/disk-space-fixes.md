# Disk space — common fixes (Omarchy / Arch, btrfs)

System: btrfs single device `/dev/mapper/root`, mounted at `/`, `/home`,
`/var/log`, `/var/cache/pacman/pkg`. Snapshots via **snapper** (config `root`,
stored in `/.snapshots`) with **limine-snapper-sync** keeping boot entries in sync.

The background monitor (`~/.local/bin/disk-usage-alert`, run by the
`disk-usage-alert.timer` user timer every 4h) fires a critical notification
when usage > 85%. When it does, work top-down through this list.

---

## 1. Snapper snapshots (the usual culprit)

Snapshots pile up from automatic timeline + pre/post-pacman snapshots and can
eat tens of GB.

### View them / how much space they use
```bash
# List all root snapshots (number, type, date, description)
sudo snapper -c root list

# Total btrfs usage picture (real free space, not what `df` claims)
sudo btrfs filesystem usage /
```
`df` is misleading on btrfs. For **per-snapshot space**, btrfs needs quotas on:
```bash
sudo btrfs quota enable /
sudo btrfs quota rescan -w /          # wait for it to finish
sudo btrfs qgroup show -p --raw / | sort -k2 -h   # 'excl' col = space freed if deleted
```
The `excl` (exclusive) column is the key number — that's what you actually
reclaim by deleting that snapshot. Shared data shows in `excl` only once.

### Remove unwanted ones
```bash
sudo snapper -c root delete 42            # one snapshot by number
sudo snapper -c root delete 30-45         # an inclusive range
sudo snapper -c root delete 30 31 36      # a specific set
```
Then reclaim happens in the background; force it with:
```bash
sudo btrfs filesystem usage /             # re-check free space
```
limine-snapper-sync updates the boot menu automatically (it watches
`/.snapshots`). If boot entries look stale: `sudo limine-snapper-sync`.

**Never delete snapshot 0** (the live system reference). Keep at least one known-good pre-update snapshot.

### Stop them coming back so fast
Edit retention limits in `/etc/snapper/configs/root`, then they self-prune:
```ini
TIMELINE_LIMIT_HOURLY="5"
TIMELINE_LIMIT_DAILY="7"
TIMELINE_LIMIT_WEEKLY="0"
TIMELINE_LIMIT_MONTHLY="0"
NUMBER_LIMIT="10"
NUMBER_LIMIT_IMPORTANT="5"
```
Apply cleanup now: `sudo snapper -c root cleanup number && sudo snapper -c root cleanup timeline`

---

## 2. Pacman package cache (currently ~8.5G)
```bash
du -sh /var/cache/pacman/pkg              # check size
sudo paccache -r                          # keep last 3 versions of each pkg
sudo paccache -rk1                         # keep only the most recent (more aggressive)
sudo paccache -ruk0                        # remove ALL cached uninstalled pkgs
```
`paccache` comes from the `pacman-contrib` package.

---

## 3. systemd journal logs
```bash
journalctl --disk-usage                   # how big it is
sudo journalctl --vacuum-size=200M        # cap to 200 MB
sudo journalctl --vacuum-time=2weeks      # or by age
```

---

## 4. Orphan packages & big offenders
```bash
# Orphaned deps no longer needed
pacman -Qtdq | sudo pacman -Rns -          # (no-op if none)

# Largest installed packages
pacman -Qi | awk '/^Name/{n=$3} /^Installed Size/{print $4$5, n}' | sort -h | tail -20

# Largest dirs in home (interactive browser; install via: omarchy pkg add ncdu)
ncdu ~
```

---

## 5. Caches in home
```bash
du -sh ~/.cache                            # check
rm -rf ~/.cache/*                          # safe to clear; apps rebuild it
# Other common hogs:
du -sh ~/.local/share/Trash ~/.cache/yay ~/.cache/paru 2>/dev/null
```

---

## Quick triage order when the alert fires
1. `sudo snapper -c root list` → delete old snapshots (biggest, fastest win)
2. `sudo paccache -rk1` → reclaim package cache
3. `sudo journalctl --vacuum-size=200M`
4. `ncdu ~` → hunt anything else
5. Re-check: `sudo btrfs filesystem usage /`
