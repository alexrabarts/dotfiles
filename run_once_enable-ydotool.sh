#!/bin/bash
# Enable ydotool service for keystroke injection
# This script runs once per machine via chezmoi's run_once mechanism

# Check if ydotool is installed
if ! command -v ydotool &> /dev/null; then
    echo "ydotool is not installed. Install it with: sudo pacman -S ydotool"
    exit 0
fi

# Enable and start ydotoold service for the user
if systemctl --user is-enabled ydotool &> /dev/null; then
    echo "ydotool service is already enabled"
else
    echo "Enabling ydotool service..."
    systemctl --user enable ydotool
fi

if systemctl --user is-active ydotool &> /dev/null; then
    echo "ydotool service is already running"
else
    echo "Starting ydotool service..."
    systemctl --user start ydotool
fi

echo "ydotool is now active. Your Super+W/T shortcuts should work reliably!"
