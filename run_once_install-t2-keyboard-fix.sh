#!/usr/bin/env bash
set -euo pipefail

echo "Installing T2 keyboard resume fix..."

# Create system-sleep directory if it doesn't exist
sudo mkdir -p /usr/lib/systemd/system-sleep

# Copy sleep hook script
sudo cp ~/.local/share/chezmoi/system-scripts/executable_fix-t2-keyboard /usr/lib/systemd/system-sleep/fix-t2-keyboard
sudo chmod 755 /usr/lib/systemd/system-sleep/fix-t2-keyboard

echo "  ✓ Sleep hook installed to /usr/lib/systemd/system-sleep/fix-t2-keyboard"
echo "✓ T2 keyboard resume fix installed successfully"
echo "  Note: The fix will activate automatically on next suspend/resume cycle"
