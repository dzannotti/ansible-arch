#!/bin/bash
# Limine bootloader configuration with Tokyo Night theme
set -euo pipefail

echo "Installing Limine bootloader..."
sudo pacman -S --needed --noconfirm \
    limine \
    plymouth

echo "Configuring mkinitcpio hooks for Plymouth..."
if [ ! -f /etc/mkinitcpio.conf.d/plymouth_hooks.conf ]; then
    sudo mkdir -p /etc/mkinitcpio.conf.d
    sudo tee /etc/mkinitcpio.conf.d/plymouth_hooks.conf > /dev/null <<'EOF'
# Add Plymouth for smooth boot splash
HOOKS=(base udev plymouth autodetect microcode modconf kms keymap consolefont block filesystems fsck)
EOF
    echo "Plymouth hooks configured"
    REBUILD_INITRAMFS=true
else
    echo "Plymouth hooks already configured"
    REBUILD_INITRAMFS=false
fi

echo "Configuring Limine with Tokyo Night theme..."
# Check for Limine config location (EFI or BIOS)
if [ -f /boot/EFI/limine/limine.conf ]; then
    LIMINE_CONFIG="/boot/EFI/limine/limine.conf"
elif [ -f /boot/limine/limine.conf ]; then
    LIMINE_CONFIG="/boot/limine/limine.conf"
elif [ -d /boot/EFI/limine ]; then
    LIMINE_CONFIG="/boot/EFI/limine/limine.conf"
elif [ -d /boot/limine ]; then
    LIMINE_CONFIG="/boot/limine/limine.conf"
else
    echo "Warning: Could not find Limine config directory"
    LIMINE_CONFIG=""
fi

if [ -n "$LIMINE_CONFIG" ]; then
    sudo tee "$LIMINE_CONFIG" > /dev/null <<'EOF'
### Limine bootloader configuration with Tokyo Night theme
timeout: 3
default_entry: 0
interface_branding: Arch Linux
interface_branding_color: 2
hash_mismatch_panic: no

# Tokyo Night color scheme
term_background: 1a1b26
backdrop: 1a1b26

# Terminal colors (Tokyo Night palette)
term_palette: 15161e;f7768e;9ece6a;e0af68;7aa2f7;bb9af7;7dcfff;a9b1d6
term_palette_bright: 414868;f7768e;9ece6a;e0af68;7aa2f7;bb9af7;7dcfff;c0caf5

# Text colors
term_foreground: c0caf5
term_foreground_bright: c0caf5
term_background_bright: 24283b

# Kernel entries will be automatically added by limine-update
EOF
    echo "Limine configuration created at $LIMINE_CONFIG"
fi

echo "Updating kernel command line for quiet boot..."
if [ -f /etc/default/grub ]; then
    if ! grep -q "quiet splash loglevel=3" /etc/default/grub; then
        sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash loglevel=3 rd.systemd.show_status=false rd.udev.log_level=3 vt.global_cursor_default=0"/' /etc/default/grub
        echo "Kernel command line updated"
        sudo grub-mkconfig -o /boot/grub/grub.cfg 2>/dev/null || true
    else
        echo "Kernel command line already configured"
    fi
fi

# Rebuild initramfs if needed
if [ "$REBUILD_INITRAMFS" = true ]; then
    echo "Rebuilding initramfs..."
    sudo mkinitcpio -P
fi

echo "Limine bootloader configured"