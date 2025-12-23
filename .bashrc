# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source ~/.local/share/omarchy/default/bash/rc

# Add your own exports, aliases, and functions here.
#
# Make an alias for invoking commands you use constantly
# alias p='python'

# Charles Edits 
# export PATH="$HOME/miniforge3/bin:$PATH"  # commented out by conda initialize
alias vim='nvim'
alias vi='nvim'
alias vd='openvpn $HOME/vpn/inc-dev-vpn.ovpn'
alias vq='openvpn $HOME/vpn/inc-qa-vpn.ovpn'
alias vp='openvpn $HOME/vpn/inc-prod-vpn.ovpn'

alias openvpn-rootless='sudo setcap cap_net_admin+ep $(which openvpn)'

ds() {
    cd /home/char/tradeswell/ds-ml-platform/ || return
    conda activate ds-ml-platform
}


# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
#__conda_setup="$('/home/char/miniforge3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
#if [ $? -eq 0 ]; then
#    eval "$__conda_setup"
#else
#    if [ -f "/home/char/miniforge3/etc/profile.d/conda.sh" ]; then
#        . "/home/char/miniforge3/etc/profile.d/conda.sh"
#    else
#        export PATH="/home/char/miniforge3/bin:$PATH"
#    fi
#fi
#unset __conda_setup
# <<< conda initialize <<<

# Conda only for interactive shells
if [ -n "$PS1" ] && [ -f /home/char/miniforge3/etc/profile.d/conda.sh ]; then
    . /home/char/miniforge3/etc/profile.d/conda.sh
fi

