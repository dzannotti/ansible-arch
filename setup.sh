#!/bin/bash

# Main script for Arch Linux workstation setup
# Direct port of site.yml structure to bash

set -euo pipefail

echo "Configure Arch Linux workstation"

# Establish sudo session at the beginning
sudo echo "Starting system setup (sudo session established)..."

# System update
scripts/update.sh

# Core system setup
scripts/base.sh

# System services
scripts/yay.sh
scripts/audio.sh
scripts/hardware.sh

# Display and desktop
scripts/display.sh
scripts/fonts.sh
scripts/desktop.sh

# Applications
scripts/development.sh
scripts/applications.sh

# System configuration
scripts/swap.sh
scripts/other-services.sh

# User configuration
scripts/zsh.sh
scripts/genssh.sh
scripts/git-config.sh

# Display manager
scripts/gdm.sh

# Desktop theming
scripts/theming.sh

# Boot experience
scripts/limine.sh
scripts/plymouth.sh

# Final upgrade
scripts/upgrade.sh

echo "Arch Linux workstation setup complete!"