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

# Define global colors for all scripts
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export PURPLE='\033[0;35m'
export CYAN='\033[0;36m'
export WHITE='\033[1;37m'
export BOLD='\033[1m'
export NC='\033[0m' # No Color

# Helper functions for colored output
success() { echo -e "${GREEN}✅ $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; }
warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
highlight() { echo -e "${CYAN}$1${NC}"; }

# Establish sudo session
info "=== Establishing sudo session ==="
sudo echo "Established sudo session" 

# System update
info "=== System Update ==="
source scripts/update.sh
success "✅ System update completed"
cd "$SCRIPT_DIR"

# Core system setup
info "=== Core System Setup ==="
source scripts/base.sh
success "✅ Core system setup completed"
cd "$SCRIPT_DIR"

# Install yay early (needed for AUR packages in other scripts)
info "=== Installing AUR Helper ==="
source scripts/yay.sh
success "✅ AUR helper installation completed"
cd "$SCRIPT_DIR"

# Boot experience (early for visual feedback)
info "=== Boot Experience ==="
source scripts/limine.sh
success "✅ Limine bootloader configuration completed"
cd "$SCRIPT_DIR"
source scripts/plymouth.sh
success "✅ Plymouth boot splash configuration completed"
cd "$SCRIPT_DIR"

# System services
info "=== System Services ==="
source scripts/audio.sh
success "✅ Audio system configuration completed"
cd "$SCRIPT_DIR"
source scripts/hardware.sh
success "✅ Hardware support configuration completed"
cd "$SCRIPT_DIR"
source scripts/other-services.sh
success "✅ System services configuration completed"
cd "$SCRIPT_DIR"

# Display and desktop
info "=== Display and Desktop ===
source scripts/display.sh
success "✅ Display system configuration completed"
cd "$SCRIPT_DIR"
source scripts/fonts.sh
success "✅ Font installation completed"
cd "$SCRIPT_DIR"
source scripts/desktop.sh
success "✅ Desktop environment installation completed"
cd "$SCRIPT_DIR"
source scripts/gdm.sh
success "✅ GDM display manager configuration completed"
cd "$SCRIPT_DIR"

# Applications
info "=== Applications ===
source scripts/development.sh
success "✅ Development tools installation completed"
cd "$SCRIPT_DIR"
source scripts/applications.sh
success "✅ Desktop applications installation completed"
cd "$SCRIPT_DIR"

# User configuration
info "=== User Configuration ===
source scripts/user-config.sh
success "✅ User configuration completed"
cd "$SCRIPT_DIR"
source scripts/zsh.sh
success "✅ Zsh shell configuration completed"
cd "$SCRIPT_DIR"
source scripts/genssh.sh
success "✅ SSH key generation completed"
cd "$SCRIPT_DIR"
source scripts/git-config.sh
success "✅ Git configuration completed"
cd "$SCRIPT_DIR"

# Desktop theming
info "=== Desktop Theming ===
source scripts/theming.sh
success "✅ Desktop theming completed"
cd "$SCRIPT_DIR"

# Final upgrade
info "=== Final Upgrade ==="
source scripts/upgrade.sh
success "✅ Final system upgrade completed"
cd "$SCRIPT_DIR"

echo "Arch Linux workstation setup complete!"