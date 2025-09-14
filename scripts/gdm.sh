#!/bin/bash
# GDM display manager installation and configuration
set -euo pipefail

echo "Installing GDM display manager..."
if ! sudo pacman -S --needed --noconfirm gdm; then
    error "Failed to install GDM!"
    warning "You may need to manually install: sudo pacman -S gdm"
    exit 1
fi

echo "Disabling other display managers if present..."
for dm in sddm lightdm; do
    if systemctl list-unit-files | grep -q "$dm.service"; then
        echo "Disabling $dm..."
        sudo systemctl disable "$dm" 2>/dev/null || true
        sudo systemctl stop "$dm" 2>/dev/null || true
    fi
done

echo "Verifying GDM installation..."
if ! pacman -Q gdm &>/dev/null; then
    error "GDM is not installed! Installation may have failed."
    exit 1
fi
success "GDM package installed successfully"

echo "Enabling GDM service (will start on next boot)..."
# Only enable, don't start - to avoid interrupting the setup
if sudo systemctl enable gdm; then
    success "GDM service enabled"
else
    error "Failed to enable GDM service"
    exit 1
fi

echo "GDM display manager configured (will be active after reboot)"

