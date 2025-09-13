#!/bin/bash

# Main script for Arch Linux workstation setup
# Sources all scripts to maintain sudo session and shared config

set -euo pipefail

# Get script directory and change to it to ensure relative paths work
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "Configure Arch Linux workstation"

# Load configuration once for all scripts
source config.sh

# Establish sudo session
echo "=== Establishing sudo session ==="
sudo echo "Established sudo session" 

# System update
echo "=== System Update ==="
source scripts/update.sh
cd "$SCRIPT_DIR"

# Core system setup
echo "=== Core System Setup ==="
source scripts/base.sh
cd "$SCRIPT_DIR"

# Boot experience (early for visual feedback)
echo "=== Boot Experience ==="
source scripts/limine.sh
cd "$SCRIPT_DIR"
source scripts/plymouth.sh
cd "$SCRIPT_DIR"

# System services
echo "=== System Services ==="
source scripts/yay.sh
cd "$SCRIPT_DIR"
source scripts/audio.sh
cd "$SCRIPT_DIR"
source scripts/hardware.sh
cd "$SCRIPT_DIR"
source scripts/other-services.sh
cd "$SCRIPT_DIR"

# Display and desktop
echo "=== Display and Desktop ==="
source scripts/display.sh
cd "$SCRIPT_DIR"
source scripts/fonts.sh
cd "$SCRIPT_DIR"
source scripts/desktop.sh
cd "$SCRIPT_DIR"
source scripts/gdm.sh
cd "$SCRIPT_DIR"

# Applications
echo "=== Applications ==="
source scripts/development.sh
cd "$SCRIPT_DIR"
source scripts/applications.sh
cd "$SCRIPT_DIR"

# User configuration
echo "=== User Configuration ==="
source scripts/user-config.sh
cd "$SCRIPT_DIR"
source scripts/zsh.sh
cd "$SCRIPT_DIR"
source scripts/genssh.sh
cd "$SCRIPT_DIR"
source scripts/git-config.sh
cd "$SCRIPT_DIR"

# Desktop theming
echo "=== Desktop Theming ==="
source scripts/theming.sh
cd "$SCRIPT_DIR"

# Final upgrade
echo "=== Final Upgrade ==="
source scripts/upgrade.sh
cd "$SCRIPT_DIR"

echo "Arch Linux workstation setup complete!"