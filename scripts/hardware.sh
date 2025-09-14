#!/bin/bash
# Hardware support - CPU, GPU, monitoring tools
set -euo pipefail

# Variables from setup.sh working directory
CONFIG_DIR="configs"

echo "Installing AMD microcode..."
sudo pacman -S --needed --noconfirm \
    amd-ucode

echo "Installing hardware monitoring tools..."
sudo pacman -S --needed --noconfirm \
    acpi \
    btop \
    cpupower \
    turbostat \
    lm_sensors

echo "Installing NVIDIA drivers..."
sudo pacman -S --needed --noconfirm \
    nvidia \
    nvidia-utils \
    nvidia-settings

echo "Configuring NVIDIA DRM kernel mode setting for Wayland..."
if [ ! -f /etc/modprobe.d/nvidia.conf ] || ! cmp -s "$CONFIG_DIR/nvidia-modprobe.conf" /etc/modprobe.d/nvidia.conf 2>/dev/null; then
    sudo cp "$CONFIG_DIR/nvidia-modprobe.conf" /etc/modprobe.d/nvidia.conf
    echo "Created/updated nvidia.conf"
else
    echo "nvidia.conf already up to date"
fi

echo "Adding NVIDIA modules to mkinitcpio.conf..."
# Use omarchy's approach - safely remove duplicates then add all modules
MKINITCPIO_CONF="/etc/mkinitcpio.conf"
NVIDIA_MODULES="nvidia nvidia_modeset nvidia_uvm nvidia_drm"

# Make a backup before modifying
if [ ! -f "$MKINITCPIO_CONF.backup" ]; then
    sudo cp "$MKINITCPIO_CONF" "$MKINITCPIO_CONF.backup"
fi

# Always add NVIDIA modules (they should be in MODULES line)
echo "Ensuring NVIDIA modules are in mkinitcpio.conf..."

# Check current MODULES line
CURRENT_MODULES=$(grep "^MODULES=" "$MKINITCPIO_CONF" || echo "")
echo "Current MODULES line: $CURRENT_MODULES"

if echo "$CURRENT_MODULES" | grep -q "nvidia nvidia_modeset nvidia_uvm nvidia_drm"; then
    echo "All NVIDIA modules already present"
else
    echo "Adding NVIDIA modules to MODULES line"
    
    # Remove any old nvidia modules to prevent duplicates
    sudo sed -i -E 's/ nvidia_drm//g; s/ nvidia_uvm//g; s/ nvidia_modeset//g; s/ nvidia//g;' "$MKINITCPIO_CONF"
    
    # Add the new modules at the start of the MODULES array
    sudo sed -i -E "s/^(MODULES=\\()/\\1${NVIDIA_MODULES} /" "$MKINITCPIO_CONF"
    
    # Clean up potential double spaces
    sudo sed -i -E 's/  +/ /g' "$MKINITCPIO_CONF"
    
    # Show the updated line
    NEW_MODULES=$(grep "^MODULES=" "$MKINITCPIO_CONF")
    echo "Updated MODULES line: $NEW_MODULES"
    
    echo "NVIDIA modules added to mkinitcpio.conf"
fi

echo "Enabling NVIDIA power management services..."
sudo systemctl enable nvidia-suspend
sudo systemctl enable nvidia-hibernate
sudo systemctl enable nvidia-resume

echo "Installing Bluetooth support..."
sudo pacman -S --needed --noconfirm \
    bluez \
    bluez-utils \
    bluez-plugins \
    blueman

echo "Enabling Bluetooth service..."
sudo systemctl enable bluetooth
sudo systemctl start bluetooth

echo "Hardware support installed"