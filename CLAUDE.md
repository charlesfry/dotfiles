# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Personal dotfiles for an **Omarchy** (Arch Linux + Hyprland) setup. There is no
build or test suite — the repo is driven entirely by Bash scripts that copy
config into place and provision the machine. Configs target Omarchy's layering
model, not vanilla upstream apps.

## Commands

```sh
bash setup.sh                      # full provision: packages, conda, brave, vpn, configs, disk-monitor, themes, reload
bash scripts/copy-confs.sh         # only re-deploy config/ → ~/.config (and ~/.bashrc); most common iteration loop
bash scripts/reload.sh             # hyprctl reload + re-source ~/.bashrc to apply changes
diskcheck                          # run the disk-usage check on demand (diskcheck 1 forces an alert regardless of usage)
emergency-clean                    # interactive reclaim across docker/conda/~/.cache/pacman/journal/snapshots
```

Individual `scripts/*.sh` are idempotent and can be run standalone; `setup.sh`
just sequences them. Re-running is safe (installers skip when already present,
config deploys back up first).

## How config deployment works (`scripts/copy-confs.sh`)

This is the heart of the repo and the key thing to understand before editing:

- **Files are copied, not symlinked.** Editing `~/.config/foo` does NOT change
  the repo — edit `config/foo` here and re-run `copy-confs.sh`. The script
  *aborts* if a destination is a symlink (unsupported).
- `CONFIGS=(alacritty bashrc hypr nvim shell waybar)` is the deploy list. The
  `bashrc` entry is special-cased to `~/.bashrc`; everything else goes to
  `~/.config/<name>`. **Adding a new config dir means adding it to this array.**
- Existing real files/dirs are moved to `backup/.bak-<timestamp>/` before being
  overwritten — backups accumulate there and in `backup/vpn-<timestamp>/`.
- After the main copy, `customs/` is overlaid on top (see below).

## Machine-specific overrides (`customs/`)

`customs/` mirrors the `~/.config` tree and is copied *last*, overwriting the
deployed defaults for this specific machine. `.gitignore` tracks only
`*.example` files plus directory structure — real override files are local and
untracked. Pattern: commit `customs/hypr/monitors.conf.example`, keep the real
`customs/hypr/monitors.conf` local. Use this for anything per-machine (monitor
layout, etc.) rather than editing the shared `config/`.

## Omarchy layering (Hyprland configs)

`config/hypr/hyprland.conf` sources Omarchy's defaults from
`~/.local/share/omarchy/default/hypr/` and the active theme from
`~/.config/omarchy/current/theme/`, *then* sources the local `config/hypr/*.conf`
files which override them. Never edit the `~/.local/share/omarchy/default/`
files directly — put overrides in the repo's `config/hypr/*.conf`. The
`omarchy` skill is the authority for Hyprland/waybar/walker/terminal/theme
customization — use it for those.

## Disk-usage monitoring subsystem

A self-contained subsystem (`disk-monitor/`, `scripts/disk-monitor.sh`,
`scripts/docker-subvolume.sh`, plus `diskcheck`/`emergency-clean` in `.bashrc`):

- A systemd **user** timer runs `~/.local/bin/disk-usage-alert` every 4h and
  sends a critical desktop notification with diagnostics when `/` exceeds 85%.
- Reporting btrfs snapshot reclaimable size needs root, so a read-only helper
  (`disk-snapshot-usage`) is installed root-owned in `/usr/local/sbin/` and
  whitelisted via `/etc/sudoers.d/disk-usage-alert` (validated with `visudo -c`).
- `docker-subvolume.sh` makes `/var/lib/docker` its own btrfs subvolume so
  docker layers are excluded from snapshots — without this, deleting images
  frees nothing while old snapshots still pin them. See `disk-monitor/README.md`
  and the deployed `~/disk-space-fixes.md` playbook.

## VPN (`scripts/vpn.sh`)

Copies `vpn/*.ovpn` (gitignored) to `~/vpn/` and generates `~/vpn/.vpnrc` with
one alias per profile: `v<first-letter>` → `sudo openvpn <profile>` (e.g. `vd`
for `dev-vpn`). **First letters must be unique across profiles** or the script
aborts. `.bashrc` sources `~/vpn/.vpnrc`.

## Conventions

- New scripts: `#!/usr/bin/env bash` + `set -Eeuo pipefail`; resolve repo root
  with `ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"`.
- Keep installers idempotent (check-then-install) since `setup.sh` re-runs them.
- `.env` (gitignored, see `.env.default`) holds secrets like `AWS_KEY` / `GH_TOKEN`.
