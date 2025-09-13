#!/bin/bash
# Desktop applications - browsers, media, productivity
set -euo pipefail

echo "Installing desktop applications from pacman..."
sudo pacman -S --needed --noconfirm \
    vlc \
    ffmpeg \
    libreoffice-fresh \
    rofi \
    copyq \
    obsidian \
    flameshot \
    qbittorrent \
    yt-dlp \
    aria2 \
    bitwarden

echo "Installing desktop applications from AUR..."
yay -S --needed --noconfirm \
    brave-bin \
    spotify \
    gallery-dl \
    ferdium \
    zoom

echo "Desktop applications installed"