#!/bin/bash

# Main script for Arch Linux workstation setup
# Sources all scripts to maintain sudo session and shared config

set -euo pipefail

echo "Configure Arch Linux workstation"

# Load configuration once for all scripts
source config.sh

# Establish sudo session
echo "=== Establishing sudo session ==="
sudo echo "Established sudo session" 

# System update
echo "=== System Update ==="
source scripts/update.sh

# Core system setup
echo "=== Core System Setup ==="
source scripts/base.sh

# Boot experience (early for visual feedback)
echo "=== Boot Experience ==="
source scripts/limine.sh
source scripts/plymouth.sh

# System services
echo "=== System Services ==="
source scripts/yay.sh
source scripts/audio.sh
source scripts/hardware.sh

# System configuration
echo "=== System Configuration ==="
source scripts/system-config.sh
source scripts/swap.sh
source scripts/other-services.sh

# Display and desktop
echo "=== Display and Desktop ==="
source scripts/display.sh
source scripts/fonts.sh
source scripts/desktop.sh
source scripts/gdm.sh

# Applications
echo "=== Applications ==="
source scripts/development.sh
source scripts/applications.sh

# User configuration
echo "=== User Configuration ==="
source scripts/user-config.sh
source scripts/zsh.sh
source scripts/genssh.sh
source scripts/git-config.sh

# Desktop theming
echo "=== Desktop Theming ==="
source scripts/theming.sh

# Final upgrade
echo "=== Final Upgrade ==="
source scripts/upgrade.sh

echo "Arch Linux workstation setup complete!"