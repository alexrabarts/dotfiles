# System Configuration Files

This repository tracks some system-level configuration files that require root access to install. These files are **not** automatically applied by `chezmoi apply` and must be installed manually.

## Linux systemd-logind Configuration

**File:** `dot_etc_logind.conf` → `/etc/systemd/logind.conf`

**Purpose:** Configures systemd-logind to ignore lid switch and power key events (useful for laptops running Hyprland where you want to handle power management yourself).

**Key settings:**
- `HandlePowerKey=ignore` - Don't suspend on power button press
- `HandleLidSwitch=ignore` - Don't suspend on lid close
- `HandleLidSwitchExternalPower=ignore` - Don't suspend on lid close even with external power
- `HandleLidSwitchDocked=ignore` - Don't suspend on lid close when docked

**Installation:**

```bash
# Copy the file to /etc/
sudo cp ~/.local/share/chezmoi/dot_etc_logind.conf /etc/systemd/logind.conf

# Restart systemd-logind to apply changes
sudo systemctl restart systemd-logind
```

**Note:** You may need to log out and log back in for changes to take full effect.

## Keyboard Backlight (kbdlightd)

The keyboard backlight daemon requires additional system-level setup:

**Files:**
- `bin/executable_kbdlightd` → `/usr/local/bin/kbdlightd`
- `bin/executable_set-kbd-brightness` → `/usr/local/bin/set-kbd-brightness`

**Installation:**

```bash
# Copy scripts to /usr/local/bin/
sudo cp ~/.local/share/chezmoi/bin/executable_kbdlightd /usr/local/bin/kbdlightd
sudo cp ~/.local/share/chezmoi/bin/executable_set-kbd-brightness /usr/local/bin/set-kbd-brightness
sudo chmod 755 /usr/local/bin/kbdlightd /usr/local/bin/set-kbd-brightness

# Create sudoers rule for passwordless brightness control
echo 'alex ALL=(ALL) NOPASSWD: /usr/local/bin/set-kbd-brightness' | sudo tee /etc/sudoers.d/kbdlightd
sudo chmod 0440 /etc/sudoers.d/kbdlightd

# Validate sudoers configuration
sudo visudo -c

# Enable and start the service
systemctl --user enable --now kbdlightd
```

Replace `alex` with your username if different.
