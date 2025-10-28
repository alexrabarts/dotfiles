#!/usr/bin/env bash
set -euo pipefail

echo "Creating udev rule to skip MTP probing for T2 devices..."

# Create udev rule to prevent unnecessary MTP device probing during suspend/resume
# This speeds up resume time by skipping MTP enumeration attempts on Apple T2 USB devices
sudo tee /etc/udev/rules.d/69-no-mtp-t2.rules >/dev/null <<'EOF'
# Skip MTP probing for Apple T2 devices to speed up resume
SUBSYSTEM=="usb", ATTR{idVendor}=="05ac", ENV{ID_MTP_DEVICE_NO_PROBE}="1"
EOF

# Reload udev rules
sudo udevadm control --reload-rules

echo "  ✓ Udev rule created at /etc/udev/rules.d/69-no-mtp-t2.rules"
echo "✓ MTP probing disabled for T2 devices"
echo "  Note: This will take effect on next boot or when devices are re-enumerated"
