#!/bin/bash
# Install yay AUR helper
set -euo pipefail

# Check if yay is already installed
if command -v yay &> /dev/null; then
    echo "yay is already installed"
    return 0
fi

echo "Installing yay AUR helper..."

# Clone yay from AUR and build
cd /tmp
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm

# Clean up
cd /
rm -rf /tmp/yay

echo "yay installed"