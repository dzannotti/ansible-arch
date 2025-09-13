#!/bin/bash
# GNOME theming - Tokyonight GTK theme and Bibata Ice cursor
set -euo pipefail

echo "Installing cursor theme from AUR..."
yay -S --needed --noconfirm \
    bibata-cursor-theme

echo "Setting up Tokyonight GTK theme..."
if [ ! -d "$HOME/.themes/Tokyonight-Dark-BL-LB" ]; then
    echo "Cloning Tokyonight GTK theme..."
    rm -rf /tmp/tokyonight-gtk-theme
    git clone https://github.com/Fausto-Korpsvart/Tokyonight-GTK-Theme.git /tmp/tokyonight-gtk-theme
    
    echo "Installing Tokyonight theme..."
    cd /tmp/tokyonight-gtk-theme
    ./install.sh -s compact -l --tweaks macos
    
    echo "Installing Tokyonight icons..."
    mkdir -p "$HOME/.local/share/icons"
    cp -r /tmp/tokyonight-gtk-theme/icons/Tokyonight-* "$HOME/.local/share/icons/" 2>/dev/null || true
    
    # Also ensure legacy location exists in case some apps still use it
    if [ ! -d "$HOME/.icons" ]; then
        ln -sf "$HOME/.local/share/icons" "$HOME/.icons"
    fi
    
    echo "Cleaning up..."
    rm -rf /tmp/tokyonight-gtk-theme
    
    echo "Tokyonight theme installed"
else
    echo "Tokyonight theme already installed"
fi

echo "Configuring GNOME themes..."

# Set GTK theme
dconf write /org/gnome/desktop/interface/gtk-theme "'Tokyonight-Dark-BL-LB'"

# Set icon theme
dconf write /org/gnome/desktop/interface/icon-theme "'Tokyonight-Dark'"

# Set cursor theme
dconf write /org/gnome/desktop/interface/cursor-theme "'Bibata-Modern-Ice'"

echo "GNOME theming complete"