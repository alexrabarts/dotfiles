#!/usr/bin/env bash
set -euo pipefail

echo "Installing keyboard backlight scripts..."

# Copy scripts to /usr/local/bin/
sudo cp ~/.local/share/chezmoi/bin/executable_kbdlightd /usr/local/bin/kbdlightd
sudo cp ~/.local/share/chezmoi/bin/executable_set-kbd-brightness /usr/local/bin/set-kbd-brightness
sudo cp ~/.local/share/chezmoi/bin/executable_kbd-backlight-up /usr/local/bin/kbd-backlight-up
sudo cp ~/.local/share/chezmoi/bin/executable_kbd-backlight-down /usr/local/bin/kbd-backlight-down
sudo cp ~/.local/share/chezmoi/bin/executable_kbd-backlight-toggle /usr/local/bin/kbd-backlight-toggle
sudo chmod 755 /usr/local/bin/kbdlightd /usr/local/bin/set-kbd-brightness /usr/local/bin/kbd-backlight-*

echo "  ✓ Scripts copied to /usr/local/bin/"

# Create sudoers rule for passwordless keyboard backlight control
sudo tee /etc/sudoers.d/kbd-backlight > /dev/null <<'EOF'
alex ALL=(ALL) NOPASSWD: /usr/local/bin/set-kbd-brightness
alex ALL=(ALL) NOPASSWD: /bin/tee /sys/class/leds/apple\:\:kbd_backlight/brightness
alex ALL=(ALL) NOPASSWD: /bin/tee /sys/class/leds/dell\:\:kbd_backlight/brightness
EOF

sudo chmod 0440 /etc/sudoers.d/kbd-backlight

echo "  ✓ Sudoers configured"

# Validate sudoers configuration
if sudo visudo -c; then
  echo "  ✓ Sudoers validation passed"
else
  echo "  ✗ Sudoers validation failed" >&2
  exit 1
fi

echo "✓ Keyboard backlight scripts installed successfully"
echo "  Note: Run 'systemctl --user enable --now kbdlightd' to enable auto-backlight daemon"
