# dotfiles

Personal [Omarchy](https://omarchy.org) (Arch Linux + Hyprland) setup. Cloning
this repo and running `setup.sh` takes a clean Omarchy machine and provisions it
to match: installs packages, deploys configs, sets up a Neovim data-science
environment, VPN aliases, disk-usage monitoring, and more.

```sh
git clone git@github.com:charlesfry/dotfiles.git ~/dotfiles
cd ~/dotfiles
bash setup.sh
```

`setup.sh` is **idempotent** — installers skip work that's already done, and
config deployment backs up whatever it replaces. Re-running it is safe; it's
also the easiest way to pull updates onto an existing machine (the `dotfiles`
shell function does exactly this).

> Configs are **copied, not symlinked**. Edit the files in this repo and re-run
> (or `bash scripts/copy-confs.sh`); editing `~/.config` directly does not change
> the repo.

## What `setup.sh` changes on your system

Each step is a standalone script in `scripts/` and can be run on its own.

| Step | Script | What it does |
|------|--------|--------------|
| 📦 Packages | `pacman-packages.sh` | Installs via `pacman`: `wget`, `bitwarden`, `pacman-contrib`, `ncdu`, `rsync`, `direnv`, `fd`, `imagemagick`. Skips anything already installed. |
| 🐍 Conda | `install-miniforge3.sh` | Installs Miniforge3 to `~/miniforge3` (skipped if `conda` already exists). |
| 🌐 Browser | `brave-with-gpu.sh` | Installs Brave (if missing) and a Wayland launcher at `/usr/local/bin/brave-wayland` + a desktop entry, when a GPU is detected. |
| 🧹 De-bloat | `remove-bloat.sh` | Removes preinstalled Omarchy webapps: HEY, Basecamp, WhatsApp, YouTube, Figma, Zoom. |
| 🔐 VPN | `vpn.sh` | Copies `vpn/*.ovpn` → `~/vpn/` and generates `~/vpn/.vpnrc` with a `v<first-letter>` alias per profile (e.g. `vd` → `sudo openvpn dev-vpn`). `.bashrc` sources it. |
| 📋 Configs | `copy-confs.sh` | Deploys `config/` → `~/.config` and `config/.bashrc` → `~/.bashrc`, backing up anything it overwrites to `backup/.bak-<timestamp>/`, then overlays machine-specific `customs/`. |
| 🔧 Git | `git-config.sh` | Sets global git config: `co`/`br`/`ci`/`st` aliases, `pull.rebase`, `push.autoSetupRemote`, `rerere`, histogram/colorMoved diffs, branch/tag sort, and `gh` as the credential helper. No identity (that's personalization). |
| 🧑 Personalize | `personalize.sh` | Prompts *"Make this a Charles PC?"* — if yes, sets the git identity and installs `personal/bashrc.personal` → `~/.bashrc.personal` (work/school shell functions). A generic install skips this. |
| 🧠 Neovim DS | `neovim-deps.sh` | Best-effort: builds a conda-independent Python host at `~/.venvs/neovim` (pynvim, jupyter_client, jupytext, cairosvg) for the Neovim Jupyter stack, and links `jupytext` into `~/.local/bin`. |
| 💽 Disk monitor | `disk-monitor.sh` | Installs a systemd **user** timer that alerts when `/` exceeds 85%, the `disk-usage-alert` script, a root-owned read-only snapshot helper + a narrow sudoers whitelist, and enables btrfs quota. See [`disk-monitor/`](disk-monitor/). |
| 🐳 Docker | `docker-subvolume.sh` | Converts `/var/lib/docker` into its own btrfs subvolume so docker layers are excluded from snapshots (idempotent; skipped if not btrfs or already done). |
| 🔄 Reload | `reload.sh` | `hyprctl reload` + re-source `~/.bashrc`. |
| 🎨 Themes | `themes.sh` | Optionally installs a curated set of Omarchy themes (prompted) plus the bundled `themes/daemon` theme. |

### Root / system-level changes worth knowing

- **Packages** installed with `sudo pacman`.
- `/usr/local/bin/brave-wayland` (Brave Wayland launcher).
- `/usr/local/sbin/disk-snapshot-usage` (root-owned) + `/etc/sudoers.d/disk-usage-alert` (passwordless sudo for **only** that read-only helper).
- `btrfs quota enable /` and `/var/lib/docker` migrated to a dedicated subvolume.
- A systemd **user** timer (`disk-usage-alert.timer`, runs every 4h while logged in).

## What ends up in your home directory

- **Shell** — `~/.bashrc` (sources Omarchy defaults, adds PATH, VPN aliases,
  conda init, git helpers `gu`/`gur`, disk helpers `diskcheck`/`emergency-clean`,
  and an "in case of emergency" disk-space reference block). On a Charles PC,
  also `~/.bashrc.personal`.
- **`~/.config/`** — `alacritty`, `hypr` (Hyprland, layered over Omarchy
  defaults — see [`CLAUDE.md`](CLAUDE.md)), `nvim`, `waybar`.
- **`~/vpn/`** — OpenVPN profiles + generated `.vpnrc`.
- **`~/miniforge3/`**, **`~/.venvs/neovim/`**, **`~/.local/bin/`** helpers,
  **`~/disk-space-fixes.md`** (disk remediation playbook).

## Repo layout

```
setup.sh            Master installer — runs the scripts/ steps in order
scripts/            One script per provisioning step (all idempotent, standalone)
config/             Dotfiles deployed to ~/.config and ~/.bashrc
  nvim/             LazyVim config + data-science layer — see config/nvim/README.md
customs/            Machine-specific overrides (only *.example tracked)
personal/           Charles-only bits, installed by personalize.sh
vpn/                OpenVPN profiles (*.ovpn gitignored) + alias generator
themes/             Bundled Omarchy theme(s)
disk-monitor/       Disk-usage monitor sources — see disk-monitor/README.md
backup/             Timestamped backups of replaced configs (gitignored)
```

## Notable extras

- **Neovim** is a LazyVim setup with a full data-science layer (Claude Code
  integration, IPython REPL, Jupyter/molten, conda venv selection, SQL, CSV
  viewing). Setup and keymaps: [`config/nvim/README.md`](config/nvim/README.md).
- **Disk-usage monitoring** alerts before `/` fills and ships
  `diskcheck` / `emergency-clean` helpers: [`disk-monitor/`](disk-monitor/).
- **Secrets** stay out of the repo: `.ovpn` files, `backup/`, and `.env`
  (see `.env.default`) are gitignored.

For architecture and conventions when modifying the repo, see [`CLAUDE.md`](CLAUDE.md).
