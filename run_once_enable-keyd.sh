#!/bin/bash
# Enable and start keyd service for keyboard remapping
# This script runs once per machine via chezmoi's run_once mechanism

# Check if keyd is installed
if ! command -v keyd &> /dev/null; then
    echo "keyd is not installed. Install it with: sudo pacman -S keyd"
    exit 0
fi

# Copy keyd configuration to /etc/keyd/
echo "Installing keyd configuration..."
sudo mkdir -p /etc/keyd
sudo cp -f ~/.local/share/chezmoi/keyd-config/default.conf /etc/keyd/default.conf
sudo chmod 644 /etc/keyd/default.conf

# Check if keyd service is already enabled
if systemctl is-enabled keyd &> /dev/null; then
    echo "keyd service is already enabled"
else
    echo "Enabling keyd service..."
    sudo systemctl enable keyd
fi

# Check if keyd service is running
if systemctl is-active keyd &> /dev/null; then
    echo "keyd service is already running, restarting to load new configuration..."
    sudo systemctl restart keyd
else
    echo "Starting keyd service..."
    sudo systemctl start keyd
fi

echo "keyd is now active. Your Alt+arrow text navigation shortcuts are ready!"
echo "Note: Using Alt instead of Super to avoid conflicts with Hyprland keybindings."
