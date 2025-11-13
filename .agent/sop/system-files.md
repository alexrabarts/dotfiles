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

## OpenSSH Server

**Files:**
- `etc/ssh/sshd_config.tmpl` → `/etc/ssh/sshd_config`
- `run_once_enable-ssh.sh` → enables and restarts `sshd`

**Purpose:** Configures the OpenSSH server with hardened defaults (no password auth, no root logins, verbose logging) and ensures the daemon is enabled on boot.

**Installation:**

```bash
chezmoi apply
./run_once_enable-ssh.sh
```

The helper script renders the template with `chezmoi execute-template`, validates it with `sshd -t`, installs it to `/etc/ssh/sshd_config`, enables the `sshd` service, and starts or reloads the daemon. Re-run the script whenever you update the configuration.

If this is the first time enabling sshd on the machine, the script also runs `ssh-keygen -A` to generate host keys before validation.

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

## keyd Keyboard Remapping

**File:** `etc/keyd/default.conf` → `/etc/keyd/default.conf`

**Purpose:** Provides kernel-level remappings (Super → Ctrl shortcuts, Alt+Shift tab switching) used across Hyprland and apps.

**Installation:**

```bash
sudo mkdir -p /etc/keyd
sudo cp ~/.local/share/chezmoi/etc/keyd/default.conf /etc/keyd/default.conf
sudo chmod 644 /etc/keyd/default.conf
sudo systemctl restart keyd
```

The `run_once_enable-keyd.sh` script performs the same steps automatically when chezmoi is applied on a new machine.

## T2 Keyboard Resume Fix

**File:** `system-scripts/executable_fix-t2-keyboard` → `/usr/lib/systemd/system-sleep/fix-t2-keyboard`

**Purpose:** Ensures the built-in T2 keyboard is immediately responsive after suspend/resume by rebinding the USB device and restarting `keyd`.

**Installation:**

```bash
sudo mkdir -p /usr/lib/systemd/system-sleep
sudo cp ~/.local/share/chezmoi/system-scripts/executable_fix-t2-keyboard /usr/lib/systemd/system-sleep/fix-t2-keyboard
sudo chmod 755 /usr/lib/systemd/system-sleep/fix-t2-keyboard
```

The `run_onchange_install-t2-keyboard-fix.sh` helper performs these steps automatically (and re-runs when the script changes). After copying, the fix takes effect on the next suspend/resume cycle.

## Suspend Mode (s2idle) Configuration

**Files:**
- `system-scripts/executable_set-s2idle` → `/usr/local/sbin/set-s2idle`
- `etc/systemd/system/set-s2idle.service` → `/etc/systemd/system/set-s2idle.service`
- `run_onchange_enable-s2idle.sh` → installs the script and enables the service

**Purpose:** Forces the system to use suspend-to-idle (s2idle) instead of deep sleep (S3), avoiding resume crashes in the `apple_bce` driver on T2 hardware.

**Installation:**

```bash
chezmoi apply
./run_onchange_enable-s2idle.sh
```

The helper copies the script to `/usr/local/sbin`, installs the systemd unit, reloads the daemon, enables the service, and ensures `/sys/power/mem_sleep` is set to `s2idle` immediately. Re-run it whenever you change the script or service.

## Fingerprint Reader Setup (ThinkPad T480s)

### Hardware
- **Device**: Synaptics Metallica MIS Touch Fingerprint Reader (06cb:009a)
- **Location**: ThinkPad T480s built-in fingerprint reader

### Required Packages
The standard `fprintd` doesn't support this device. You need:
- `python-validity` (AUR) - Driver for Synaptics "Match on Host" devices
- `python-validity` dependencies are automatically installed

### Installation Steps

1. **Install the driver**:
```bash
yay -S python-validity
```

2. **Mask standard fprintd** (to avoid conflicts):
```bash
sudo systemctl mask fprintd
```

3. **Enable services**:
```bash
sudo systemctl enable --now python3-validity
sudo systemctl enable --now open-fprintd
```

4. **Enroll fingerprint**:
```bash
fprintd-enroll $USER
```

5. **Configure PAM** (for sudo, polkit, and hyprlock authentication):
```bash
sudo sed -i '1i auth    sufficient pam_fprintd.so' /etc/pam.d/sudo
sudo sed -i '1i auth      sufficient pam_fprintd.so' /etc/pam.d/polkit-1
sudo sed -i '2i auth      sufficient pam_fprintd.so' /etc/pam.d/system-auth
```

The system-auth configuration enables fingerprint for hyprlock and other system authentication.

6. **Test**:
```bash
fprintd-verify $USER
```

### Verification
Check enrolled fingerprints:
```bash
fprintd-list $USER
```

Should show:
```
found 1 devices
Device at /net/reactivated/Fprint/Device/0
Fingerprints for user alex on DBus driver (press):
 - #0: right-index-finger
```

### Enrollment Tips

**Common issue**: Many `enroll-retry-scan` messages followed by `enroll-failed`

**Solutions**:
- **Use light touch**: Firm pressure causes failures. Light, consistent touch works best.
- **Clean sensor**: Wipe fingerprint reader with microfiber cloth
- **Prepare finger**: Wash and dry hands (slightly moist is ideal, not too dry or wet)
- **Be consistent**: Use same angle, same part of finger, hold still 1-2 seconds per scan
- **Enroll different finger**: If one finger keeps failing, try another:
  ```bash
  fprintd-enroll -f right-thumb $USER
  fprintd-enroll -f left-index-finger $USER
  ```
- **Delete and retry**: If finger already enrolled, delete first:
  ```bash
  fprintd-delete $USER
  fprintd-enroll $USER
  ```

### Notes
- The `python-validity` driver works with "Match on Host" Synaptics devices
- Do NOT use `libfprint-2-tod1-synatudor-git` - that's for different Synaptics models
- The Omarchy fingerprint setup script won't work with this device (expects standard fprintd)
- After setup, fingerprint auth works for:
  - `sudo` commands
  - GUI privilege escalation (polkit)
  - **Hyprlock screen unlock** (via system-auth PAM)
- Hyprlock config already has `fingerprint:enabled = true` in `~/.config/hypr/hyprlock.conf`

### Related Files
- Services: `python3-validity.service`, `open-fprintd.service`
- PAM config: `/etc/pam.d/sudo`, `/etc/pam.d/polkit-1`, `/etc/pam.d/system-auth`
- Device data: `~/.local/share/python-validity/` (encrypted fingerprint templates)
- Hyprlock config: `~/.config/hypr/hyprlock.conf`
