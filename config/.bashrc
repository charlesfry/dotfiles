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
    conda activate ml4t
    cd /home/char/gatech/ml4t/ || return
    echo "Moved to $(pwd) directory and activated ml4t conda environment."

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

