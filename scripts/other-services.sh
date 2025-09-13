#!/bin/bash
# Essential system services
set -euo pipefail

echo "Enabling NetworkManager..."
sudo systemctl enable NetworkManager
sudo systemctl start NetworkManager

echo "Enabling network discovery (Avahi)..."
sudo systemctl enable avahi-daemon
sudo systemctl start avahi-daemon

echo "Enabling GNOME Keyring..."
systemctl --user enable gnome-keyring-daemon

echo "Enabling power profiles daemon..."
sudo systemctl enable power-profiles-daemon
sudo systemctl start power-profiles-daemon

echo "Setting performance power profile..."
powerprofilesctl set performance || true

echo "Enabling SSH daemon..."
sudo systemctl enable sshd

echo "Enabling firewall..."
sudo systemctl enable ufw

echo "Essential services configured"