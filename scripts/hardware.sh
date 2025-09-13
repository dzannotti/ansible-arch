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

# NVIDIA drivers (optional - uncomment to enable)
# echo "Installing NVIDIA drivers..."
# sudo pacman -S --needed --noconfirm \
#     nvidia \
#     nvidia-utils \
#     nvidia-settings \
#     lib32-nvidia-utils

# echo "Configuring NVIDIA DRM kernel mode setting for Wayland..."
# sudo tee /etc/modprobe.d/nvidia.conf > /dev/null <<'EOF'
# options nvidia_drm modeset=1
# options nvidia_drm fbdev=1
# options nvidia NVreg_PreserveVideoMemoryAllocations=1
# options nvidia NVreg_TemporaryFilePath=/var/tmp
# EOF

# echo "Enabling NVIDIA power management services..."
# sudo systemctl enable nvidia-suspend
# sudo systemctl enable nvidia-hibernate
# sudo systemctl enable nvidia-resume

# Bluetooth support (optional - uncomment to enable)
# echo "Installing Bluetooth support..."
# sudo pacman -S --needed --noconfirm \
#     bluez \
#     bluez-utils \
#     bluez-plugins \
#     blueman

# echo "Enabling Bluetooth service..."
# sudo systemctl enable bluetooth
# sudo systemctl start bluetooth

echo "Hardware support installed"