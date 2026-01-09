#!/bin/bash
set -Eeuo pipefail

### CONFIG ###
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"  # ../ from install/ to repo root
SRC_DIR="$ROOT_DIR/vpn"

# Backup existing $HOME/vpn if it exists
if [[ -d "$HOME/vpn" ]]; then
    BACKUP_DIR="$ROOT_DIR/backup"
    mkdir -p "$BACKUP_DIR"
    timestamp=$(date +%Y%m%d_%H%M%S)
    backup_path="$BACKUP_DIR/vpn-$timestamp"
    echo "Backing up existing $HOME/vpn to $backup_path"
    mv "$HOME/vpn" "$backup_path"
fi

echo "Copying vpn files from $SRC_DIR to $HOME/vpn"
mkdir -p "$HOME/vpn"
cp -r "$SRC_DIR"/*.ovpn "$HOME/vpn/"

VPN_RC="$HOME/vpn/.vpnrc"

# make sure .vpnrc exists
touch "$VPN_RC"

# for each .ovpn file, add a line to .vpnrc to create an alias to connect
# Format: alias vd='openvpn $HOME/vpn/dev-vpn.ovpn'

declare -A first_letters_seen=()  # associative array to track first letters

for ovpn_file in "$HOME/vpn/"*.ovpn; do
    if [[ -f "$ovpn_file" ]]; then
      vpn_name=$(basename "$ovpn_file" .ovpn)
      first_letter=${vpn_name:0:1}       # get first letter
      # Check if this first letter was already used
      if [[ -n "${first_letters_seen[$first_letter]:-}" ]]; then
          echo "ERROR: Multiple VPNs start with the letter '$first_letter'. Aborting."
          exit 1
      fi
      first_letters_seen[$first_letter]=1  # mark this letter as seen
      alias_name="v$first_letter" # alias like 'vd'
      echo "alias $alias_name='openvpn \"$HOME/vpn/$vpn_name.ovpn\"'" >> "$VPN_RC"
    fi
done

# add rootless command
echo "alias openvpn-rootless='sudo setcap cap_net_admin+ep $(which openvpn)'" >> "$VPN_RC"

echo "Aliases added to $VPN_RC."

