#!/bin/bash
# Git configuration
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load configuration
source "$SCRIPT_DIR/../config.sh"

echo "Configuring Git settings..."

# User settings
git config --global user.email "$SETUP_EMAIL"
git config --global user.name "$SETUP_FULL_NAME"

# Repository settings
git config --global init.defaultBranch "main"
git config --global pull.rebase "false"
git config --global push.autoSetupRemote "true"

# Editor and pager
git config --global core.editor "nvim"
git config --global core.pager "delta"

# Delta (git-delta) configuration
git config --global interactive.diffFilter "delta --color-only"
git config --global delta.navigate "true"
git config --global delta.light "false"
git config --global delta.side-by-side "true"

# Diff and merge settings
git config --global merge.conflictstyle "diff3"
git config --global diff.colorMoved "default"

echo "Git configuration complete"