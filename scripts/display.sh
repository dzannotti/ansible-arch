#!/bin/bash
# Display system - Wayland with XWayland compatibility
set -euo pipefail

echo "Installing XWayland compatibility layer..."
sudo pacman -S --needed --noconfirm \
    xorg-xwayland

echo "Installing Wayland base packages..."
sudo pacman -S --needed --noconfirm \
    wayland \
    wayland-protocols \
    qt5-wayland \
    qt6-wayland \
    wl-clipboard \
    wtype \
    slurp

echo "Display system installed"