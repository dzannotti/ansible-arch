#!/bin/bash
# Upgrade all packages (pacman + AUR)
set -euo pipefail

echo "Upgrading all packages..."
yay -Syu --noconfirm

echo "System upgrade complete"