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
REBUILD_INITRAMFS=false

# Check and add each NVIDIA module individually
for module in nvidia nvidia_modeset nvidia_uvm nvidia_drm; do
    if ! grep -q "MODULES=.*$module" /etc/mkinitcpio.conf; then
        # Add module to the MODULES array
        sudo sed -i "/^MODULES=/s/)/ $module)/" /etc/mkinitcpio.conf
        echo "Added $module to mkinitcpio.conf"
        REBUILD_INITRAMFS=true
    fi
done

# Clean up any duplicate spaces in MODULES line
sudo sed -i '/^MODULES=/s/  */ /g' /etc/mkinitcpio.conf
sudo sed -i '/^MODULES=/s/( /(/g' /etc/mkinitcpio.conf

if [ "$REBUILD_INITRAMFS" = true ]; then
    echo "Rebuilding initramfs..."
    sudo mkinitcpio -P
    echo "NVIDIA modules added to mkinitcpio.conf"
else
    echo "NVIDIA modules already present in mkinitcpio.conf"
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