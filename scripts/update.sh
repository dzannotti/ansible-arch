#!/bin/bash
# Update package cache
set -euo pipefail

echo "Updating package cache..."
sudo pacman -Sy

echo "Package cache updated"