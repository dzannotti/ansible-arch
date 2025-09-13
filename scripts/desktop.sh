#!/bin/bash
# Desktop environment - GNOME on Wayland
set -euo pipefail

echo "Installing GNOME desktop components..."
sudo pacman -S --needed --noconfirm \
    libnotify \
    gnome-keyring \
    gnome-control-center \
    gnome-tweaks \
    gnome-shell \
    gnome-shell-extensions \
    gnome-themes-extra \
    nautilus \
    file-roller \
    evince \
    gnome-calculator \
    gnome-text-editor \
    gnome-disk-utility \
    gtk3 \
    gtk4 \
    libadwaita \
    gtk-engine-murrine \
    sassc \
    qt6-svg \
    qt6-virtualkeyboard \
    qt6-multimedia-ffmpeg

echo "GNOME desktop environment installed"