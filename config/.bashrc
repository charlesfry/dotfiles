# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
source ~/.local/share/omarchy/default/bash/rc

alias vim='nvim'
alias vi='nvim'
alias vd='openvpn $HOME/vpn/inc-dev-vpn.ovpn'
alias vq='openvpn $HOME/vpn/inc-qa-vpn.ovpn'
alias vp='openvpn $HOME/vpn/inc-prod-vpn.ovpn'

alias openvpn-rootless='sudo setcap cap_net_admin+ep $(which openvpn)'

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

