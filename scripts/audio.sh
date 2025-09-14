#!/bin/bash
# Audio system (PipeWire)
set -euo pipefail

echo "Installing PipeWire audio system..."

sudo pacman -S --needed --noconfirm \
    pipewire \
    pipewire-alsa \
    pipewire-pulse \
    pipewire-jack \
    wireplumber \
    alsa-utils \
    pavucontrol \
    gst-plugin-pipewire \
    pipewire-v4l2

echo "Enabling PipeWire user services..."

systemctl --user enable pipewire
systemctl --user enable pipewire-pulse  
systemctl --user enable wireplumber

# Start services now if we're in a user session
if [ -n "${XDG_RUNTIME_DIR:-}" ]; then
    systemctl --user start pipewire
    systemctl --user start pipewire-pulse
    systemctl --user start wireplumber
    echo "PipeWire services started"
else
    echo "PipeWire services enabled (will start on next login)"
fi

echo "PipeWire audio system installed"