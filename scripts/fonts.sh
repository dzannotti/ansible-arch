#!/bin/bash
# Font installation
set -euo pipefail

echo "Installing essential system fonts from pacman..."
sudo pacman -S --needed --noconfirm \
    noto-fonts \
    noto-fonts-cjk \
    noto-fonts-emoji \
    ttf-liberation

echo "Installing programming and custom fonts from AUR..."
yay -S --needed --noconfirm \
    ttf-cascadia-code-nerd \
    ttf-firacode-nerd \
    ttf-geist \
    ttf-geist-mono \
    ttf-ms-fonts \
    otf-san-francisco

echo "Fonts installed"