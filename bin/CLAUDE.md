# bin/ Directory Documentation

This directory contains utility scripts that are symlinked to `~/bin/` by chezmoi. These scripts provide system-level functionality and development tools.

## Overview

All scripts are prefixed with `executable_` in the source directory to ensure they have executable permissions after being applied by chezmoi. The scripts support both macOS and Linux with appropriate platform detection.

## Scripts

### go-install

**Purpose**: Install specific Go versions from official releases to `~/local/go`

**Platform**: Cross-platform (Linux/macOS, amd64/arm64)

**Usage**:
```bash
go-install 1.21.5
go-install 1.22.0
```

**How It Works**:
1. Auto-detects OS (Linux/Darwin) and architecture (x86_64/arm64)
2. Downloads official Go tarball from https://go.dev/dl/
3. Removes existing `~/local/go` installation
4. Extracts new version to `~/local/go`
5. Clean up temporary download

**Requirements**:
- `curl` for downloading
- Write access to `~/local/`
- PATH configured to include `~/local/go/bin` (set up in `~/.zshrc`)

**Example**:
```bash
# Install Go 1.22.1
go-install 1.22.1

# Verify installation
go version
# Output: go version go1.22.1 linux/amd64
```

**Notes**:
- This follows the official Go installation guide
- Each installation completely replaces the previous one
- Go modules installed with `go install` are in `~/go/bin/` and remain across versions
- If you need multiple Go versions simultaneously, consider using `mise` or `gvm`

### pg

**Purpose**: Smart PostgreSQL connection tool using credentials from `~/.pgpass`

**Platform**: Cross-platform (requires `psql` client)

**Usage**:
```bash
# Show available databases
pg

# Connect to specific database
pg myapp-production
pg myapp-staging
```

**How It Works**:
1. Reads `~/.pgpass` file for connection credentials
2. Parses format: `hostname:port:database:username:password`
3. Lists available databases if no argument provided
4. Connects using `psql` with credentials from matching line

**Requirements**:
- PostgreSQL client (`psql`) installed
- `~/.pgpass` file with database credentials (managed by chezmoi as encrypted)
- Proper `~/.pgpass` permissions (600)

**Features**:
- Tab completion in zsh (configured in `~/.zshrc`)
- Smart credential lookup by database name
- Shows helpful usage when no database specified
- Displays available databases with host and user info

**Example .pgpass format**:
```
localhost:5432:mydb:postgres:secretpass
prod-db.example.com:5432:production:app_user:prodpass
```

**Integration**:
The zsh completion function in `~/.zshrc` provides tab completion for database names:
```zsh
__pg_completion() {
  local -a databases
  if [ -f ~/.pgpass ]; then
    databases=(${(f)"$(awk -F: '{print $3}' ~/.pgpass | sort -u)"})
  fi
  _describe 'database' databases
}
compdef __pg_completion pg
```

### Keyboard Backlight Scripts (Linux Only)

These scripts provide keyboard backlight control for laptops (primarily MacBooks) running Linux.

#### kbd-backlight-up

**Purpose**: Increase keyboard backlight brightness by 10%

**Platform**: Linux only

**Usage**:
```bash
kbd-backlight-up
```

**Supported Devices**:
- Apple keyboards: `/sys/class/leds/apple::kbd_backlight/`
- Dell keyboards: `/sys/class/leds/dell::kbd_backlight/`

**How It Works**:
1. Auto-detects keyboard backlight device
2. Reads current brightness and max brightness
3. Increases by 10% (Apple) or 1 level (Dell)
4. Caps at maximum brightness
5. Writes new value using sudo

**Requires**: Sudo access to write to sysfs

#### kbd-backlight-down

**Purpose**: Decrease keyboard backlight brightness by 10%

**Platform**: Linux only

**Usage**:
```bash
kbd-backlight-down
```

**How It Works**: Same as `kbd-backlight-up` but decreases brightness

#### kbd-backlight-toggle

**Purpose**: Toggle keyboard backlight on/off

**Platform**: Linux only

**Usage**:
```bash
kbd-backlight-toggle
```

**How It Works**:
1. Reads current brightness
2. If currently on (> 0), turns off (sets to 0)
3. If currently off, turns on (sets to 50% of max for Apple, level 2 for Dell)

**Use Cases**:
- Quick on/off toggle
- Binding to function keys (F5/F6)
- Power saving when brightness not needed

#### set-kbd-brightness

**Purpose**: Set keyboard backlight to specific brightness level

**Platform**: Linux only

**Usage**:
```bash
# Set to specific level (0-max_brightness)
set-kbd-brightness 100
set-kbd-brightness 0  # Off
```

**How It Works**:
1. Takes brightness value as argument
2. Validates against max_brightness
3. Writes directly to sysfs brightness file

**Note**: Used by other backlight scripts and the kbdlightd daemon

#### kbdlightd

**Purpose**: Daemon that auto-dims keyboard backlight after inactivity

**Platform**: Linux only (requires X11)

**Usage**:
```bash
# Run as daemon (typically started by systemd)
kbdlightd
```

**How It Works**:
1. Monitors keyboard/mouse activity using `xprintidle`
2. After 15 seconds of inactivity, turns off keyboard backlight
3. Turns backlight back on when activity resumes
4. Remembers user's preferred brightness level
5. Respects manual brightness changes

**Behavior**:
- **Timeout**: 15 seconds of inactivity
- **Memory**: Remembers your preferred brightness level
- **Manual Override**: If you manually turn off backlight, daemon respects that and won't auto-turn-on
- **Startup**: Systemd service runs at login (see `~/.config/systemd/user/`)

**Requirements**:
- `xprintidle` command to detect idle time
- Sudo access for `set-kbd-brightness` (configured via sudoers)
- Running X11 session (not Wayland)

**Systemd Integration**:
Typically configured as a user service that starts at login. See system-scripts/ for installation.

### capslock-to-control

**Purpose**: Remap Caps Lock key to Control on macOS

**Platform**: macOS only

**Usage**:
```bash
capslock-to-control
```

**How It Works**:
1. Uses macOS `hidutil` to remap HID keyboard codes
2. Maps Caps Lock (0x700000039) to Left Control (0x7000000E0)
3. Remap persists until reboot

**Automatic Execution**:
This script is executed automatically by a Launch Agent on macOS. See:
- `Library/LaunchAgents/com.alexrabarts.swapcaps.plist`
- `run_onchange_reload-swapcaps-launchagent.sh`

**Notes**:
- Only runs on macOS (exits silently on Linux)
- Requires macOS 10.12 Sierra or later (when hidutil was introduced)
- Remap is temporary and resets on reboot (Launch Agent re-applies it)
- For Linux, use keyd configuration instead (see `keyd-config/`)

## Symlinks

### zen

**Purpose**: Symlink that provides a shortcut to another tool

**Platform**: Cross-platform

**Source**: `symlink_zen.tmpl` (templated symlink)

**How It Works**:
This is a chezmoi symlink that points to another executable. The `.tmpl` extension allows for platform-specific targets using Go templating.

**Usage**: Check the symlink target after apply:
```bash
ls -la ~/bin/zen
```

## PATH Integration

All scripts in `~/bin/` are available system-wide because `~/.zshrc` adds this directory to PATH:

```zsh
__path_prepend "$HOME/bin"
```

This uses the `__path_prepend` helper function which:
- Adds to the front of PATH (takes precedence)
- Prevents duplicate entries
- Ensures user scripts override system versions

## Maintenance

### Adding New Scripts

1. Create script in repository with `executable_` prefix:
```bash
cd ~/.local/share/chezmoi/bin
touch executable_myscript
chmod +x executable_myscript
```

2. Edit the script (remember shebang):
```bash
#!/bin/bash
# Your script content
```

3. Apply with chezmoi:
```bash
chezmoi apply
```

4. Verify installation:
```bash
which myscript
# Should show: /home/user/bin/myscript
```

### Platform-Specific Scripts

Use conditional logic at the start of scripts:

```bash
#!/bin/bash

# Only run on Linux
if [[ $(uname -s) != "Linux" ]]; then
  echo "This script requires Linux" >&2
  exit 1
fi

# ... rest of script
```

Or use `.tmpl` extension with Go template conditionals:

```bash
{{- if eq .chezmoi.os "darwin" -}}
#!/bin/bash
# macOS-specific script
{{- end }}
```

### Testing Scripts

Test scripts before committing:

```bash
# Syntax check
bash -n ~/bin/myscript

# Dry run (if script supports it)
~/bin/myscript --dry-run

# Test in isolated environment
docker run -it --rm ubuntu:latest bash
# ... install and test script
```

## Security Considerations

### Sudo Requirements

Several scripts require sudo access:
- `kbd-backlight-*` scripts
- `set-kbd-brightness`

**Setup**: Configure sudoers to allow these commands without password:
```bash
sudo visudo
# Add lines like:
user ALL=(ALL) NOPASSWD: /usr/local/bin/set-kbd-brightness
```

This is handled automatically by `run_once_install-kbd-backlight.sh`.

### Sensitive Data

Never hardcode credentials or secrets in scripts. Use:
- Encrypted files (`~/.env`, `~/.pgpass`)
- Environment variables
- Configuration files in `~/.config/`
- System keychains/credential managers

### Script Permissions

Executable scripts should be:
- Owned by your user
- Mode 755 (rwxr-xr-x) or 700 (rwx------)
- Never writable by group or other
- Chezmoi handles this via `executable_` prefix

## Troubleshooting

### Script Not Found After Apply

**Problem**: Script doesn't appear in `~/bin/` after `chezmoi apply`

**Solutions**:
1. Verify source file has `executable_` prefix
2. Check chezmoi dry-run: `chezmoi apply --dry-run -v`
3. Manually apply: `chezmoi apply -v`
4. Check for errors: `chezmoi doctor`

### Permission Denied

**Problem**: Script exists but can't execute

**Solutions**:
```bash
# Check permissions
ls -la ~/bin/scriptname

# Should be executable (755 or 700)
# If not, check source:
ls -la ~/.local/share/chezmoi/bin/executable_scriptname

# Re-apply with force
chezmoi apply --force
```

### Sudo Password Prompts

**Problem**: Backlight scripts constantly ask for sudo password

**Solution**: Scripts are designed to use sudo. Set up passwordless sudo for specific commands (see Security Considerations above).

### Wrong Tool Version

**Problem**: Running system version instead of script

**Solutions**:
```bash
# Check which version is running
which scriptname

# Should show ~/bin/scriptname
# If not, PATH order might be wrong

# Check PATH
echo $PATH

# ~/bin should appear early in PATH
# Reload shell
exec zsh
```

## Related Documentation

- **CLAUDE.md** (root) - Overall repository architecture
- **dot_zshrc.tmpl** - PATH configuration and shell integration
- **SYSTEM_FILES.md** - System-level file installations
- **run_once_install-kbd-backlight.sh** - Keyboard backlight setup
- **system-scripts/** - System-level installation scripts
