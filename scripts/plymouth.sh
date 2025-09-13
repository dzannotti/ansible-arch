#!/bin/bash
# Plymouth boot splash theme setup
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/../configs"

echo "Setting up Plymouth boot splash..."

# Create theme directory
echo "Creating Plymouth theme directory..."
sudo mkdir -p /usr/share/plymouth/themes/tokyo-night

# Copy Plymouth theme configuration
echo "Creating Plymouth theme configuration..."
sudo cp "$CONFIG_DIR/plymouth-theme.plymouth" /usr/share/plymouth/themes/tokyo-night/tokyo-night.plymouth

# Copy Plymouth script file
echo "Creating Plymouth script file..."
sudo cp "$CONFIG_DIR/plymouth-theme.script" /usr/share/plymouth/themes/tokyo-night/tokyo-night.script

# Create simple placeholder graphics if ImageMagick is available
if command -v convert &> /dev/null; then
    echo "Creating placeholder graphics..."
    if [ ! -f /usr/share/plymouth/themes/tokyo-night/logo.png ]; then
        # Logo (Arch Linux blue circle)
        sudo convert -size 64x64 xc:none -fill "#7aa2f7" -draw "circle 32,32 32,16" /usr/share/plymouth/themes/tokyo-night/logo.png
        
        # Progress box (dark rounded rectangle)
        sudo convert -size 300x20 xc:"#414868" -fill "#414868" /usr/share/plymouth/themes/tokyo-night/progress_box.png
        
        # Progress bar (Tokyo Night blue)
        sudo convert -size 300x20 xc:"#7aa2f7" -fill "#7aa2f7" /usr/share/plymouth/themes/tokyo-night/progress_bar.png
        
        echo "Placeholder graphics created"
    else
        echo "Graphics already exist"
    fi
else
    echo "ImageMagick not found, skipping placeholder graphics"
fi

# Set Tokyo Night as default Plymouth theme
echo "Setting Tokyo Night as default Plymouth theme..."
sudo plymouth-set-default-theme tokyo-night

# Enable Plymouth in systemd
echo "Enabling Plymouth service..."
sudo systemctl enable plymouth-start 2>/dev/null || true

echo "Plymouth boot splash configured"