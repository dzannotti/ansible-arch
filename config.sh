#!/bin/bash
# Central configuration file for all setup scripts
# Edit these values to match your setup

# User information
export SETUP_USERNAME="dzannotti"
export SETUP_FULL_NAME="Daniele Zannotti"
export SETUP_EMAIL="dzannotti@me.com"

# System configuration
export SETUP_HOSTNAME="labyrinth"
export SETUP_TIMEZONE="Europe/London"
export SETUP_LOCALE="en_US.UTF-8"

# Swap configuration
export SETUP_SWAPFILE_PATH="/swapfile"
export SETUP_SWAPFILE_SIZE="8G"

# Features to enable/disable
export SETUP_ENABLE_SSH=true
export SETUP_ENABLE_FIREWALL=true