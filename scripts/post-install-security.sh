#!/bin/bash

echo "Run Security hardening script? (Y/N)"
read -rsn1 -p "> " CHOICE </dev/tty

case "$CHOICE" in
  y|Y)
    echo "Running security hardening script..."
    ;;
  n|N)
    echo "Skipping security hardening."
    exit 0
    ;;
  *)
    echo "Invalid choice. Skipping security hardening."
    exit 0
    ;;
esac

sudo chown root:root $HOME/vpn/run-vpn.sh
sudo chmod 700 $HOME/vpn/run-vpn.sh

echo "Add the following line to visudo or to /etc/sudoers.d/:"
ME=$(whoami)
echo "ALL ALL=(root) NOPASSWD: /home/$ME/vpn/run-vpn.sh"
