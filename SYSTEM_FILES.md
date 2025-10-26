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

## Log Rotation Configuration

### Systemd Journal Limits

**File:** `dot_etc_systemd_journald.conf` → `/etc/systemd/journald.conf`

**Purpose:** Prevents systemd journal logs from consuming excessive disk space by setting size and retention limits.

**Key settings:**
- `SystemMaxUse=200M` - Limit total journal storage to 200MB
- `SystemKeepFree=1G` - Ensure at least 1GB stays free on disk
- `MaxRetentionSec=7day` - Keep logs for maximum 7 days

**Installation:**

```bash
# Copy the file to /etc/systemd/
sudo cp ~/.local/share/chezmoi/dot_etc_systemd_journald.conf /etc/systemd/journald.conf

# Restart journald to apply changes
sudo systemctl restart systemd-journald

# Vacuum existing logs to free space immediately
sudo journalctl --vacuum-size=200M
```

**Check current usage:**
```bash
journalctl --disk-usage
```

## Application-Specific Configuration

Application-specific system configurations (like logrotate rules, systemd services) should be kept **in the application's repository**, not in dotfiles. This keeps deployment logic with the application code.

### Example: Logrotate for Application Logs

Each application should provide its own logrotate configuration if needed:

**Structure:**
```
my-app/
├── etc/
│   └── logrotate.d/
│       └── my-app
└── Makefile (with install-logrotate target)
```

**Installation:** Run `make install-logrotate` from the application repo.

See individual application repositories for their specific system configuration needs (e.g., `swatchlab`, `property-bot`).
