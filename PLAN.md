# Dotfiles Setup Plan

## Current Work: ydotool Setup for macOS-style Keyboard Shortcuts

### Goal
Enable Super+W (close tab) and Super+T (new tab) shortcuts system-wide by using ydotool to inject Ctrl+W and Ctrl+T keystrokes.

### Why ydotool?
- Initial attempt with `wtype` was unreliable - Super+W worked but Super+T was flaky
- `keyd` for Alt+arrow navigation interfered with wtype and broke Super+Alt+Space (Omarchy menu)
- ydotool works at a lower level and should be more reliable

### Current Status
- ✅ Scripts created: `bin/send-ctrl-w` and `bin/send-ctrl-t` using ydotool
- ✅ Hyprland bindings configured: Super+W and Super+T
- ✅ Super+D remapped to toggle floating (was Super+T)
- ✅ ydotool package added to pkglist.txt
- ✅ Permission setup script created: `run_once_setup-ydotool-permissions.sh`
- ✅ Service enablement script created: `run_once_enable-ydotool.sh`
- ⚠️  keyd removed from package list but config files still in repo
- ❌ ydotool permissions not yet configured
- ❌ User not in input group yet
- ❌ ydotoold service not running

### Next Steps (After Restart)

1. **Install ydotool** (if not already installed):
   ```bash
   cd ~/repos/github.com/alexrabarts/dotfiles
   sudo pacman -S ydotool
   ```

2. **Setup permissions**:
   ```bash
   bash run_once_setup-ydotool-permissions.sh
   ```

   This script will:
   - Create udev rule for /dev/uinput access
   - Add your user to the `input` group
   - Reload udev rules
   - Load uinput kernel module
   - Configure uinput to load on boot

3. **Log out and log back in** (required for group changes to take effect)

4. **After logging back in, start ydotool service**:
   ```bash
   systemctl --user enable --now ydotool
   systemctl --user status ydotool  # Verify it's running
   ```

5. **Copy scripts** (if not already applied by chezmoi):
   ```bash
   cd ~/repos/github.com/alexrabarts/dotfiles
   cp bin/send-ctrl-w ~/bin/send-ctrl-w
   cp bin/send-ctrl-t ~/bin/send-ctrl-t
   chmod +x ~/bin/send-ctrl-*
   ```

6. **Test the shortcuts**:
   - Open a browser
   - Press Super+T → should open new tab
   - Press Super+W → should close tab
   - Test Super+Alt+Space → should open Omarchy settings menu (not app launcher)

7. **If working, commit and push**:
   ```bash
   git add bin/send-ctrl-* dot_config/pkglist.txt run_once_*.sh dot_config/hypr/bindings.conf.tmpl
   git commit -m "Replace wtype with ydotool for reliable Super+W/T shortcuts"
   git push
   ```

### Files Modified/Created

**Scripts:**
- `bin/send-ctrl-w` - Uses ydotool to send Ctrl+W
- `bin/send-ctrl-t` - Uses ydotool to send Ctrl+T

**Hyprland:**
- `dot_config/hypr/bindings.conf.tmpl` - Super+W, Super+T, Super+D bindings

**Setup:**
- `run_once_setup-ydotool-permissions.sh` - Setup udev rules and permissions
- `run_once_enable-ydotool.sh` - Enable ydotool service (not needed if manual steps followed)

**Packages:**
- Added: ydotool
- Removed: wtype (can be removed once ydotool is confirmed working)
- Removed: keyd (was interfering with shortcuts)

### Cleanup TODO (After ydotool is confirmed working)

1. Remove keyd config files:
   ```bash
   git rm -r keyd-config/ run_once_enable-keyd.sh
   ```

2. Remove wtype from package list (replace with ydotool):
   ```bash
   # Edit dot_config/pkglist.txt - remove wtype line
   ```

3. Update CLAUDE.md if needed to document the Super+W/T shortcuts

### Troubleshooting

**If ydotool service fails to start:**
- Check logs: `journalctl --user -u ydotool -n 50`
- Verify uinput device exists: `ls -la /dev/uinput`
- Verify you're in input group: `groups | grep input`
- Check udev rule: `cat /etc/udev/rules.d/80-uinput.rules`

**If shortcuts don't work:**
- Test ydotool directly: `ydotool key 29:1 20:1 20:0 29:0` (should send Ctrl+T)
- Check socket exists: `ls -la /run/user/1000/.ydotool_socket`
- Test scripts manually: `~/bin/send-ctrl-t`

**If Super+Alt+Space doesn't open Omarchy menu:**
- keyd might still be running - disable it: `sudo systemctl stop keyd && sudo systemctl disable keyd`

### Alternative Approach (If ydotool still doesn't work)

Give up on system-wide Super+W/T shortcuts and just use standard Linux shortcuts:
- Use Ctrl+W for close tab
- Use Ctrl+T for new tab
- Remove the custom Hyprland bindings
- This is what most Linux users do and it's 100% reliable

### Key Bindings Summary

After setup completes:
- **Super+W** → Close tab (Ctrl+W)
- **Super+T** → New tab (Ctrl+T)
- **Super+Q** → Close window (killactive)
- **Super+D** → Toggle floating (moved from Super+T)
- **Super+Alt+Space** → Omarchy settings menu
- **Super+Space** → App launcher
