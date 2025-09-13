#!/bin/bash
# GDM display manager installation and configuration
set -euo pipefail

echo "Installing GDM display manager..."
sudo pacman -S --needed --noconfirm \
    gdm

echo "Disabling other display managers if present..."
for dm in sddm lightdm; do
    if systemctl list-unit-files | grep -q "$dm.service"; then
        echo "Disabling $dm..."
        sudo systemctl disable "$dm" 2>/dev/null || true
        sudo systemctl stop "$dm" 2>/dev/null || true
    fi
done

echo "Enabling GDM service..."
sudo systemctl enable gdm
sudo systemctl daemon-reload

echo "GDM display manager configured"