This is my Omarchy setup

Install using setup.sh

```sh
bash setup.sh
```

## Disk-usage monitoring

`setup.sh` installs a disk-usage monitor (systemd user timer that alerts at
>85% with diagnostics), the `diskcheck` / `emergency-clean` shell helpers, and
makes `/var/lib/docker` its own btrfs subvolume so docker layers stay out of
snapshots. See [`disk-monitor/`](disk-monitor/) and `~/disk-space-fixes.md`.
