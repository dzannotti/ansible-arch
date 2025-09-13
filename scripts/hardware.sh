#!/bin/bash
# Hardware support - CPU, GPU, monitoring tools
set -euo pipefail

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
    nvidia-settings \
    lib32-nvidia-utils

echo "Configuring NVIDIA DRM kernel mode setting for Wayland..."
if [ ! -f /etc/modprobe.d/nvidia.conf ]; then
    sudo tee /etc/modprobe.d/nvidia.conf > /dev/null <<'EOF'
options nvidia_drm modeset=1
options nvidia_drm fbdev=1
options nvidia NVreg_PreserveVideoMemoryAllocations=1
options nvidia NVreg_TemporaryFilePath=/var/tmp
EOF
    echo "Created nvidia.conf"
else
    echo "nvidia.conf already exists"
fi

echo "Adding NVIDIA modules to mkinitcpio.conf..."
if ! grep -q "nvidia" /etc/mkinitcpio.conf; then
    sudo sed -i 's/^MODULES=(\(.*\))/MODULES=(\1 nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
    sudo sed -i 's/MODULES=( /MODULES=(/' /etc/mkinitcpio.conf
    sudo sed -i 's/  / /g' /etc/mkinitcpio.conf
    
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