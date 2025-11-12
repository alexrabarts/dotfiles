# Known Issues

Known problems, in-progress work, and blocked items that require attention.

## ✅ RESOLVED: Walker DMenu Mode Breaks After Reboot

### Issue
Omarchy menu submenus would fail to appear after system reboot. Walker's `--dmenu` mode would get into a bad state.

### Root Cause
Walker service (walker --gapplication-service) and elephant processes can get into a bad state after reboot, causing dmenu mode to become non-responsive.

### Solution Implemented
Added automatic walker/elephant restart on Hyprland startup:
- File: `dot_config/hypr/autostart.conf`
- Command: `exec-once = pkill walker; pkill elephant`
- Effect: Ensures clean walker state on every login

### Manual Fix (if needed mid-session)
```bash
make restart-walker
```

### Related Documentation
- `.agent/sop/learnings.md:167` - Full diagnostic details and investigation
- `dot_config/hypr/autostart.conf:5` - Permanent fix implementation

## 🚧 IN PROGRESS: T2 Keyboard Resume After Suspend

### Issue
The built-in Apple T2 keyboard doesn't reconnect immediately after opening the laptop lid (post-suspend). Key input fails until the keyboard is manually unplugged/replugged.

### Root Cause
1. **Deep sleep (S3) causes kernel panic**: The `apple_bce` driver crashes on resume from S3
2. **USB rebinding needed**: Even with s2idle, the T2 keyboard USB device needs to be rebound after resume

### Current Solution

**s2idle enforcement** (prevents kernel panic):
- `system-scripts/executable_set-s2idle` → `/usr/local/sbin/set-s2idle`
- `etc/systemd/system/set-s2idle.service` → `/etc/systemd/system/set-s2idle.service`
- Forces system to use suspend-to-idle instead of S3
- Installed via `run_onchange_enable-s2idle.sh`

**Automatic USB rebinding after resume**:
- `system-scripts/executable_fix-t2-keyboard` → `/usr/lib/systemd/system-sleep/fix-t2-keyboard`
- Runs after resume, waits for USB to settle, rebinds T2 keyboard device, restarts keyd
- Uses guarded rebind loop (5 tries) to handle timing issues
- Logs to both systemd journal and `/var/log/fix-t2-keyboard.log`
- Installed via `run_onchange_install-t2-keyboard-fix.sh`

### Testing & Verification

**Installation**:
```bash
chezmoi apply
./run_onchange_enable-s2idle.sh
./run_onchange_install-t2-keyboard-fix.sh
```

**After suspend/resume**:
```bash
# Check logs
tail -n 50 /var/log/fix-t2-keyboard.log
journalctl -t fix-t2-keyboard -b | tail -n 50

# Manual trigger for testing
sudo /usr/lib/systemd/system-sleep/fix-t2-keyboard post suspend
```

**Success indicators**:
- Log shows: `Unbound 5-5` → `Rebound 5-5 successfully` → `Restarted keyd` → `Rebind successful`
- Keyboard works immediately after lid open
- No need to unplug/replug

### Next Steps
- TODO: Report the `apple_bce` Oops upstream
- TODO: Revisit enabling S3 once a fix lands in the kernel
- Monitor for false negatives (resume works but script thinks it failed)

### Related Files
- `.agent/sop/system-files.md` - Installation instructions for system-level components
- `etc/systemd/system/set-s2idle.service`
- `system-scripts/executable_set-s2idle`
- `system-scripts/executable_fix-t2-keyboard`
- `run_onchange_enable-s2idle.sh.tmpl`
- `run_onchange_install-t2-keyboard-fix.sh`

## 🛑 BLOCKED: tmux Option+Arrow Window Navigation

### Goal
Use Option+Left/Right (and Shift variants) to cycle tmux windows, while keeping Option+[ / ] bindings and preserving shell word navigation (Meta+b / Meta+f) when desired.

### Problem
Ghostty terminal emulator sends `^[b` and `^[f` (Meta+b / Meta+f) for Option+Arrow keys, which conflicts with shell word navigation. Attempts to remap these sequences in Ghostty have failed.

### What's Been Tried

1. **Standard CSI sequences in tmux**
   - Added tmux bindings for `\e[1;3D`, etc. with `xterm-keys` enabled
   - Result: Option+Arrow still acted as Meta+b / Meta+f, bindings never triggered

2. **Custom Ghostty escape sequences**
   - Patched Ghostty config to emit `\u001b[1;9D` / `\u001b[1;10D` for Option+Arrow
   - Bound these sequences in tmux
   - Result: After reload, `cat -v` still showed `^[b` / `^[f`
   - Ghostty appears to ignore custom `keybind` directives when `macos-option-as-alt=true`

3. **Verification**
   - Tested with `printf 'Press Option+Left: '; cat -v`
   - Confirmed tmux receives plain Meta+b / Meta+f sequences

### Current Workaround
Use Option+[ and Option+] for tmux window navigation (these work correctly).

### Potential Solutions to Investigate

1. **Ghostty config location**
   - Double-check where Ghostty expects the config when managed by chezmoi
   - Verify `keybind` directives are actually being loaded
   - Check Application Support vs. `~/Library/Preferences`

2. **Karabiner-Elements (macOS only)**
   - Could rewrite Option+Arrow to unique escape sequences at the system level
   - Would work before terminal sees the keys
   - Requires additional system-level tool

3. **Alternative terminal emulator**
   - Test if other terminals (Alacritty, iTerm2) handle custom Option+Arrow mappings better

### Status
Blocked pending investigation of Ghostty config loading or alternative approaches. Current Option+[ / ] bindings are functional, so this is low priority.

### Related Files
- `dot_config/ghostty/config` - Ghostty terminal configuration
- `dot_config/tmux/tmux.conf` - tmux configuration
