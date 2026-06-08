# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# if sudo always results in an incorrect password, the following can fix this issue:
# omarchy-reset-sudo

# All the default Omarchy aliases and functions
source ~/.local/share/omarchy/default/bash/rc

# Add user's private bin to PATH
export PATH="$HOME/.local/bin:$PATH"

# VPN configs
source ~/vpn/.vpnrc

alias vim='nvim'
alias vi='nvim'

ds() {
    cd /home/char/tradeswell/ds-ml-platform/ || return
    conda activate ds-ml-platform
    current_branch=$(git rev-parse --abbrev-ref HEAD)
    echo "On branch: $current_branch"
}

mmm() {
    cd /home/char/tradeswell/ds-ml-platform/ || return
    conda activate mmm
    nvim /home/char/tradeswell/ds-ml-platform/
}

darts() {
    cd /home/char/tradeswell/ds-ml-platform/ || return
    conda activate darts
    nvim /home/char/tradeswell/ds-ml-platform/
}

gt() {
    conda activate gatech-ethics
    cd /home/char/gatech/gatech-ethics/ || return
    echo "Moved to $(pwd) directory and activated environment."

}

grade() {
    cd /home/char/gatech/ml4t/assess_portfolio/ || return
    conda activate ml4t
    PYTHONPATH="$HOME/gatech/ml4t" python grade_analysis.py
}

dotfiles() {
  cd /home/char/dotfiles/ || return
  /home/char/dotfiles/setup.sh
  cd - || return
}

empty-trash() {
  rm -rf $HOME/.local/share/Trash/*
  echo "Trash Emptied."
}

# Conda only for interactive shells
if [ -n "$PS1" ] && [ -f /home/char/miniforge3/etc/profile.d/conda.sh ]; then
    . /home/char/miniforge3/etc/profile.d/conda.sh
fi


gu() {
    current_branch=$(git rev-parse --abbrev-ref HEAD)

    # Check for changes (including untracked) and stash if any
    STASHED=0
    if ! git diff-index --quiet HEAD -- || [ -n "$(git ls-files --others --exclude-standard)" ]; then
        git stash -u
        STASHED=1
    fi

    git checkout main
    git pull
    git checkout "$current_branch"

    # Only pop if we actually stashed something
    if [ "$STASHED" -eq 1 ]; then
        git stash pop
    fi
    git status
}

gur() {
  gu
  git rebase main
}

check() {
    # Check the sha256sum of a file against an expected value
    if [ "$#" -ne 2 ]; then
        echo "Usage: checksha256 <file> <expected_sha256>"
        return 1
    fi

    local file="$1"
    local expected="$2"

    if [ ! -f "$file" ]; then
        echo "Error: file '$file' not found"
        return 1
    fi

    # Validate checksum format (64 hex chars)
    if [[ ! "$expected" =~ ^[A-Fa-f0-9]{64}$ ]]; then
        echo "Error: invalid SHA-256 string"
        return 1
    fi

    echo "$expected  $file" | sha256sum -c -
}

alias chad='NVIM_APPNAME=chad nvim'

emergency() {
  sudo rm /var/reserved-space.img
}

# ┌─────────────────────────────────────────────────────────────────────────┐
# │ IN CASE OF EMERGENCY, BREAK GLASS — DISK SPACE IS FULL                     │
# ├─────────────────────────────────────────────────────────────────────────┤
# │ System: btrfs on /dev/mapper/root (/, /home, /var all share it).          │
# │ Snapshots = snapper (config 'root', in /.snapshots) + limine-snapper-sync.│
# │ Full reference notes: ~/disk-space-fixes.md                               │
# │                                                                           │
# │ 1) DIAGNOSE — where did the space go? (run top-down, stop when you find it)│
# │    df -h /                                  # are we actually full?        │
# │    sudo btrfs filesystem usage /            # TRUE btrfs free space        │
# │    sudo du -xhd1 / 2>/dev/null | sort -h | tail -20    # biggest dirs on / │
# │    du -xhd1 ~ 2>/dev/null | sort -h | tail -20         # biggest in $HOME  │
# │    sudo ncdu -x /                           # interactive hunt (pacman -S) │
# │                                                                           │
# │ 2) SNAPSHOTS — diagnose                                                   │
# │    sudo snapper -c root list                # list all snapshots          │
# │    # exact reclaimable space per snapshot (the 'excl' column):            │
# │    sudo btrfs quota enable /                                              │
# │    sudo btrfs quota rescan -w /                                           │
# │    sudo btrfs qgroup show -p --raw / | sort -k3 -h                        │
#      sudo snapper -c root delete 19 20 21
# │                                                                           │
# │    SNAPSHOTS — fix (NEVER delete snapshot 0; keep 1 known-good rollback)  │
# │    sudo snapper -c root delete 19 20        # delete by number(s)         │
# │    sudo snapper -c root delete 30-45        # delete an inclusive range   │
# │    sudo snapper -c root cleanup number      # prune per retention limits  │
# │    # tame future growth: edit limits in /etc/snapper/configs/root         │
# │    #   (NUMBER_LIMIT, TIMELINE_LIMIT_DAILY/WEEKLY/MONTHLY)                 │
# │    # limine-snapper-sync fixes the boot menu automatically after deletes. │
# │                                                                           │
# │ 3) DOCKER — diagnose (you already know how to rm images/containers/cache) │
# │    docker system df                         # totals + RECLAIMABLE by type│
# │    docker system df -v                       # per image/container/volume  │
# │    docker image ls --format '{{.Size}}\t{{.Repository}}:{{.Tag}}' | sort -h│
# │    sudo du -sh /var/lib/docker              # where it all lives          │
# │                                                                           │
# │ 4) OTHER QUICK WINS                                                       │
# │    sudo paccache -rk1                        # pacman cache (pacman-contrib)│
# │    sudo journalctl --vacuum-size=200M        # systemd journal            │
# │    rm -rf ~/.cache/*                          # app caches (rebuilt later)  │
# └─────────────────────────────────────────────────────────────────────────┘

# Manually run the disk-usage check (the timer does this every 4h).
# Prints current usage, then runs the alert (fires a critical notification
# only if over threshold). Pass a threshold to force it, e.g. `diskcheck 1`.
diskcheck() {
  df -h --output=pcent,used,avail,target / | tail -n +1
  # Snapshot space needs root; gather it here (sudo may prompt) and pass it to
  # the alert via env so the notification reports the real size. Needs quota:
  # sudo btrfs quota enable /
  local cnt excl
  read -r cnt excl < <(sudo btrfs qgroup show -p --raw / 2>/dev/null | awk '
    $0 ~ /\.snapshots\/[0-9]+\/snapshot/ { e += $3; n++ } END { printf "%d %d", n+0, e+0 }')
  SNAPSHOT_COUNT="$cnt" SNAPSHOT_EXCL="$excl" \
    DISK_THRESHOLD="${1:-85}" ~/.local/bin/disk-usage-alert \
    && echo "Done (notification fires only when over ${1:-85}%)."
}

# In case of disk emergency: reclaim space across the usual offenders and
# report how much was freed. Interactive (sudo may prompt). AGGRESSIVE — wipes
# Docker build cache + ALL unused images, conda caches, ~/.cache, the pacman
# package cache, and old journals, and prunes snapshots to their retention
# limit. Pass --yes / -y to skip the confirmation.
emergency-clean() {
  local before after freed
  echo "== Disk before =="
  df -h --output=pcent,used,avail,target /
  before=$(df -B1 / | tail -1 | awk '{print $4}')

  if [[ "${1:-}" != "--yes" && "${1:-}" != "-y" ]]; then
    read -rp "Wipe Docker images/cache, conda + ~/.cache, pacman cache, old journals, and prune snapshots? [y/N] " ans
    [[ "$ans" == [yY]* ]] || { echo "Aborted."; return 1; }
  fi

  # Docker — each step independent so one failure doesn't block the rest.
  if command -v docker >/dev/null && docker info >/dev/null 2>&1; then
    echo "-> Docker (build cache, unused images, stopped containers)..."
    docker builder prune -af
    docker image prune -af
    docker container prune -f
    # docker volume prune -f   # DISABLED: deletes unused named volumes = possible DB/data loss. Enable knowingly.
  else
    echo "-> Docker not running — skipped."
  fi

  # Conda caches (tarballs, unused packages) — keeps your envs intact.
  if command -v conda >/dev/null; then
    echo "-> Conda caches..."
    conda clean -afy
  fi

  # User app cache — rebuilt on demand. Guarded so an unset $HOME can't rm /.
  echo "-> ~/.cache ..."
  rm -rf "${HOME:?HOME unset}/.cache/"* 2>/dev/null

  # Pacman PACKAGE cache (lives on / — this is the real one, not ~/.cache).
  echo "-> Pacman package cache..."
  if command -v paccache >/dev/null; then sudo paccache -rk1; else sudo pacman -Sc --noconfirm; fi

  # systemd journal.
  echo "-> Journal (cap 200M)..."
  sudo journalctl --vacuum-size=200M

  # Snapshots — prune to retention limit only (safe: keeps recent + rollback).
  echo "-> Snapshots (prune to retention limit)..."
  sudo snapper -c root cleanup number || true
  echo "   Remaining snapshots (Used Space = reclaimable; needs btrfs quota):"
  sudo snapper -c root list

  echo "== Disk after =="
  df -h --output=pcent,used,avail,target /
  after=$(df -B1 / | tail -1 | awk '{print $4}')
  freed=$((after - before))
  echo "Freed this run: $(numfmt --to=iec --suffix=B "$freed" 2>/dev/null || echo "${freed} bytes")"

  echo "Biggest remaining dirs in ~/.local:"
  du -xhd1 ~/.local 2>/dev/null | sort -h | tail
}

eval "$(direnv hook bash)"

