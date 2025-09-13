#!/bin/bash

# Main script for Arch Linux workstation setup
# Sources all scripts to maintain sudo session and shared config

set -euo pipefail

echo "Configure Arch Linux workstation"

# Load configuration once for all scripts
source config.sh

# Establish and maintain sudo session
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

echo "Starting system setup (sudo session established)..."

# System update
source scripts/update.sh

# Core system setup
source scripts/base.sh

# Boot experience (early for visual feedback)
source scripts/limine.sh
source scripts/plymouth.sh

# System services
source scripts/yay.sh
source scripts/audio.sh
source scripts/hardware.sh

# System configuration
source scripts/system-config.sh
source scripts/swap.sh
source scripts/other-services.sh

# Display and desktop
source scripts/display.sh
source scripts/fonts.sh
source scripts/desktop.sh
source scripts/gdm.sh

# Applications
source scripts/development.sh
source scripts/applications.sh

# User configuration
source scripts/user-config.sh
source scripts/zsh.sh
source scripts/genssh.sh
source scripts/git-config.sh

# Desktop theming
source scripts/theming.sh

# Final upgrade
source scripts/upgrade.sh

echo "Arch Linux workstation setup complete!"