#!/bin/bash
# System configuration - hostname and basic settings
set -euo pipefail

HOSTNAME="labyrinth"

echo "Configuring system settings..."

# Set hostname
echo "Setting hostname to $HOSTNAME..."
if [ "$(hostname)" != "$HOSTNAME" ]; then
    sudo hostnamectl set-hostname "$HOSTNAME"
    echo "Hostname set to $HOSTNAME"
else
    echo "Hostname already set to $HOSTNAME"
fi

# Update /etc/hosts if needed
if ! grep -q "127.0.0.1.*$HOSTNAME" /etc/hosts; then
    echo "Updating /etc/hosts..."
    sudo sed -i "s/127.0.0.1\s*localhost/127.0.0.1 localhost $HOSTNAME/" /etc/hosts
    echo "/etc/hosts updated"
else
    echo "/etc/hosts already configured"
fi

# Set locale if not already set
if ! localectl | grep -q "LANG=en_US.UTF-8"; then
    echo "Setting system locale to en_US.UTF-8..."
    sudo localectl set-locale LANG=en_US.UTF-8
else
    echo "Locale already set to en_US.UTF-8"
fi

# Set timezone if not already set to London
TIMEZONE="Europe/London"
if [ "$(timedatectl show --property=Timezone --value)" != "$TIMEZONE" ]; then
    echo "Setting timezone to $TIMEZONE..."
    sudo timedatectl set-timezone "$TIMEZONE"
else
    echo "Timezone already set to $TIMEZONE"
fi

echo "System configuration complete"