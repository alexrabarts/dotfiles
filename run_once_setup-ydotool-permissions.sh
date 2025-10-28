#!/bin/bash
# Setup ydotool permissions for uinput device access
# This script runs once per machine via chezmoi's run_once mechanism

# Check if ydotool is installed
if ! command -v ydotool &> /dev/null; then
    echo "ydotool is not installed. Install it with: sudo pacman -S ydotool"
    exit 0
fi

# Create udev rule for uinput permissions
echo "Creating udev rule for uinput access..."
sudo tee /etc/udev/rules.d/80-uinput.rules > /dev/null << 'EOF'
# Allow users in the input group to access /dev/uinput
KERNEL=="uinput", GROUP="input", MODE="0660"
EOF

# Add user to input group
echo "Adding $USER to input group..."
sudo usermod -aG input $USER

# Reload udev rules
echo "Reloading udev rules..."
sudo udevadm control --reload-rules
sudo udevadm trigger

# Load uinput module
echo "Loading uinput kernel module..."
sudo modprobe uinput

# Make uinput load on boot
if ! grep -q "^uinput" /etc/modules-load.d/uinput.conf 2>/dev/null; then
    echo "Adding uinput to modules-load..."
    echo "uinput" | sudo tee /etc/modules-load.d/uinput.conf > /dev/null
fi

echo ""
echo "ydotool permissions setup complete!"
echo "IMPORTANT: You must log out and log back in for group changes to take effect."
echo "After logging back in, run: systemctl --user enable --now ydotool"
