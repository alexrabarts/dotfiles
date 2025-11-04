# Dotfiles Setup Plan

## ✅ COMPLETED: macOS-style Super+T/W Keyboard Shortcuts

### Goal
Enable Super+W (close tab) and Super+T (new tab) shortcuts system-wide, working exactly like macOS.

### Solution: keyd

After trying multiple approaches (wtype, ydotool with various timing hacks), the proper solution was **keyd** with the correct configuration syntax.

**Why keyd works**: It operates at the kernel level, remapping keys BEFORE applications see them. When you press Super+T, applications only receive Ctrl+T - they never see SUPER at all.

### Final Configuration

**keyd config** (`/etc/keyd/default.conf`):
```
[ids]
*

[meta]
# macOS-style shortcuts when Super is held
# Tab management
t = C-t
w = C-w

# Text navigation
left = home
right = end
up = C-home
down = C-end
backspace = C-backspace

# Other shortcuts
l = C-l

[meta+shift]
# Text selection with Super+Shift
left = S-home
right = S-end
up = C-S-home
down = C-S-end
```

**Key insight**: The `[meta]` layer (not `meta.t` in `[main]`) is the correct syntax for remapping Super+key combinations.

**Hyprland config** (`dot_config/hypr/bindings.conf.tmpl`):
```
# Unbind Super+W and Super+T - keyd handles them at kernel level
unbind = SUPER, W
unbind = SUPER, T
unbind = SUPER, LEFT
unbind = SUPER, RIGHT
unbind = SUPER, UP
unbind = SUPER, DOWN
bindd = SUPER, Q, Close window, killactive,
bindd = SUPER, D, Toggle floating, togglefloating,
```

### What Works

**Tab Management:**
- ✅ Super+T → New tab (Ctrl+T)
- ✅ Super+W → Close tab (Ctrl+W)
- ✅ Super+L → Focus location bar/command line (Ctrl+L)

**Text Navigation:**
- ✅ Super+Left → Start of line (Home)
- ✅ Super+Right → End of line (End)
- ✅ Super+Up → Start of document (Ctrl+Home)
- ✅ Super+Down → End of document (Ctrl+End)
- ✅ Super+Backspace → Delete word left (Ctrl+Backspace)

**Text Selection:**
- ✅ Super+Shift+Left → Select to start of line (Shift+Home)
- ✅ Super+Shift+Right → Select to end of line (Shift+End)
- ✅ Super+Shift+Up → Select to start of document (Ctrl+Shift+Home)
- ✅ Super+Shift+Down → Select to end of document (Ctrl+Shift+End)

**Window Management:**
- ✅ Super+Q → Close window (Hyprland native)
- ✅ Super+D → Toggle floating (moved from Super+T)
- ✅ Super+Tab → Cycle windows (Hyprland native)
- ✅ Super+Alt+Space → Omarchy settings menu
- ✅ Super+Space → App launcher

### What Didn't Work

1. **wtype**: Unreliable - Super+W worked but Super+T was flaky
2. **ydotool with `bindd` (bind on press)**: SUPER still held down when ydotool sent Ctrl+T, creating SUPER+Ctrl+T conflict
3. **ydotool with `bindr` (bind on release)**: Only worked if you released SUPER very quickly - not natural UX
4. **ydotool with delays**: Hacky and still unreliable
5. **keyd with wrong syntax**: `meta.t = C-t` in `[main]` section didn't work - needed `[meta]` layer instead

## ✅ COMPLETED: Alt+Shift+[/] for Tab Switching

### Goal
Map Alt+Shift+[ to previous tab and Alt+Shift+] to next tab in applications (browsers, terminals, etc.), since Super+Alt+[/] is now used for Hyprland workspace navigation.

### Current Status
✅ **WORKING** - keyd composite layer emits Ctrl+Shift+Tab / Ctrl+Tab macros, restoring tab navigation.

### What We've Tried

1. **Using `leftbrace`/`rightbrace` in [alt+shift] layer**
   - Issue: These are curly braces {}, not square brackets []

2. **Using `[` and `]` in [alt+shift] composite layer**
   - Composite layer didn't trigger at all

3. **Using `shift+leftbracket` in [alt] layer**
   - Didn't work

4. **Using empty [shift] and [alt] layers with [alt+shift] composite**
   - Composite layer still didn't trigger
   - Test with mapping to 'x' and 'y' showed no output

5. **Using `A-S-leftbracket` notation in [main]**
   - Didn't work

6. **Using `alt+shift+[` notation in [main]**
   - No effect
7. **Defining `[shift:S]` and `[alt:A]` placeholders plus `[alt+shift]` composite layer (macro output)**
   - Works: `[ = macro(C-S-tab)`, `] = macro(C-tab)`
   - Managed by chezmoi at `etc/keyd/default.conf`
   - Requires copying updated config to `/etc/keyd/default.conf` (run `./run_once_enable-keyd.sh` or `sudo cp ~/.local/share/chezmoi/etc/keyd/default.conf /etc/keyd/default.conf`)
   - Reload keyd with `sudo systemctl restart keyd`

### Debug Information

From `sudo keyd listen` after deploying the working config:
```
+main
+alt
+shift
+alt+shift
...
-alt
-shift
```
This shows the composite layer activating when Alt+Shift is held.

### Files Modified

**keyd:**
- `keyd-config/default.conf` - Adds Alt+Shift composite layer emitting Ctrl+Tab macros alongside Super remaps

**Hyprland:**
- `dot_config/hypr/bindings.conf.tmpl` - Unbinds Super keys for keyd, removes Super+arrow window focus

**Packages:**
- `dot_config/pkglist.txt` - Has `keyd`, removed `ydotool`

### Setup on New Machine

The `run_once_enable-keyd.sh` script handles everything automatically:
1. Installs keyd config to `/etc/keyd/default.conf`
2. Enables and starts keyd service
3. No manual configuration needed

### Lessons Learned

- Userspace keystroke injection tools (wtype, ydotool) don't work well for modifier key remapping because the physical modifier is still pressed when synthetic keys are sent
- Kernel-level remapping (keyd, kmonad) is the proper solution for this use case
- keyd syntax is specific: use `[modifier]` layers, not `modifier.key` in `[main]`
- Always check the official documentation for syntax examples - web search results can be outdated
- `sudo keyd monitor` is essential for debugging - shows exact key names keyd detects
- Composite layers like `[alt+shift]` may not work as expected - need to find working examples
- The `[meta+shift]` composite layer works fine, so the issue is specific to `[alt+shift]`

## 🚧 IN PROGRESS: T2 Keyboard wakes after lid open

### Goal
Ensure the built-in Apple T2 keyboard reconnects immediately after opening the laptop lid (post-suspend) so key input works without unplug/replug.

### Current Status
- `system-scripts/executable_fix-t2-keyboard` pauses briefly after resume, waits for USB devices to settle, then runs a guarded USB rebind loop (5 tries) and restarts `keyd` only after a successful bind.
- `run_onchange_install-t2-keyboard-fix.sh` is executable and copies the hook into `/usr/lib/systemd/system-sleep/`; run it whenever the script changes.
- Deep sleep (S3) still triggers an `apple_bce` crash on resume; `s2idle` works reliably and is now enforced by a systemd service.

### Next Steps
- Install updated hook: `./run_onchange_install-t2-keyboard-fix.sh` (or `chezmoi apply`).
- Enforce s2idle on new machines: `./run_onchange_enable-s2idle.sh` (or `chezmoi apply`).
- Suspend, reopen lid, confirm the screen wakes and the keyboard works without replugging.
- Check logs for any failures: `tail -n 50 /var/log/fix-t2-keyboard.log` or `journalctl -t fix-t2-keyboard -b | tail -n 50`.
- If issues persist, capture the resume window from `dmesg` / `journalctl` and note whether the rebind loop logged any failures.
- TODO: Report the `apple_bce` Oops upstream and revisit enabling S3 once a fix lands.

### Debugging & Manual Testing
- The hook logs to systemd (`journalctl -t fix-t2-keyboard`) and mirrors every message to `/var/log/fix-t2-keyboard.log` (override with `FIX_T2_KEYBOARD_LOG_FILE=/path`) so you can inspect without sudo.
- Reinstall the hook after edits from the repo root: `cd ~/repos/github.com/alexrabarts/dotfiles && ./run_onchange_install-t2-keyboard-fix.sh`.
- Manual trigger with interactive logging: `sudo /usr/lib/systemd/system-sleep/fix-t2-keyboard post suspend`.
- After suspend/resume, verify success via `tail -n 50 /var/log/fix-t2-keyboard.log` or `sudo journalctl -t fix-t2-keyboard -b --no-pager | tail`.
- Typical success log sequence (manual run): `Waiting for USB devices to settle`, `Unbound 5-5`, `Rebound 5-5 successfully`, `Restarted keyd`, `Rebind successful; exiting hook`.

### Files Modified
- `system-scripts/executable_fix-t2-keyboard`
- `run_onchange_install-t2-keyboard-fix.sh`
- `SYSTEM_FILES.md`

## 🛑 BLOCKED: tmux Option+Arrow window navigation

### Goal
Let Option+Left/Right (and the Shift variants) cycle tmux windows, while keeping the existing Option+[ / ] bindings and leaving shell word navigation (Meta+b / Meta+f) intact when desired.

### Attempts
- Added tmux bindings for the standard CSI sequences used by Meta+arrow keys (`\e[1;3D`, etc.) and enabled `xterm-keys`. Result: Option+Arrow still acted as Meta+b / Meta+f inside tmux, so the new bindings never triggered.
- Patched Ghostty to emit custom escape sequences (`\u001b[1;9D` / `\u001b[1;10D`) for Option+Arrow and Shift+Option+Arrow and bound those sequences in tmux. After reload, `cat -v` inside tmux continued to show `^[b` / `^[f`, which means Ghostty is still sending the default Meta+b / Meta+f sequences despite the config change.
- Verified the sequences with `printf 'Press Option+Left: '; cat -v` (shows `^[b` and `^[f`), confirming tmux receives plain Meta+b / Meta+f.

### Current Status
Option+Arrow remains mapped to shell word navigation. The Ghostty keybinding override either is not being applied (config path?) or Ghostty ignores the custom mapping when `macos-option-as-alt=true`.

### Next Steps
- Double-check where Ghostty expects the config file when managed via chezmoi (Application Support vs. `~/Library/Preferences`); ensure `keybind` directives load.
- Alternatively, consider Karabiner-Elements to rewrite Option+Arrow to unique escape sequences before the terminal sees them.
- For now, stick with Option+[ / ] for tmux window navigation.
