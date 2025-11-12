# Learnings

Insights and lessons learned during dotfiles development and configuration.

## Keyboard Remapping: keyd vs Userspace Tools

**Problem**: Needed macOS-style Super+T/W shortcuts and other modifier-based remappings to work system-wide on Linux.

**What Didn't Work**:
- **wtype**: Unreliable - Super+W worked but Super+T was flaky
- **ydotool with `bindd` (bind on press)**: SUPER still held down when ydotool sent Ctrl+T, creating SUPER+Ctrl+T conflict
- **ydotool with `bindr` (bind on release)**: Only worked if you released SUPER very quickly - not natural UX
- **ydotool with delays**: Hacky and still unreliable

**Solution**: **keyd** - kernel-level key remapping

**Why keyd works**: It operates at the kernel level, remapping keys BEFORE applications see them. When you press Super+T, applications only receive Ctrl+T - they never see SUPER at all.

**Key Insights**:
- Userspace keystroke injection tools (wtype, ydotool) don't work well for modifier key remapping because the physical modifier is still pressed when synthetic keys are sent
- Kernel-level remapping (keyd, kmonad) is the proper solution for this use case
- keyd syntax is specific: use `[modifier]` layers, not `modifier.key` in `[main]`
- The `[meta]` layer (not `meta.t` in `[main]`) is the correct syntax for remapping Super+key combinations

## keyd Configuration Syntax

**Working configuration pattern**:
```
[ids]
*

[meta]
# macOS-style shortcuts when Super is held
t = C-t
w = C-w
left = home
right = end

[meta+shift]
# Text selection with Super+Shift
left = S-home
right = S-end
```

**Composite Layers**:
- The `[meta+shift]` composite layer works correctly
- Use `macro()` syntax for complex key sequences: `[ = macro(C-S-tab)`
- Define placeholder layers like `[shift:S]` and `[alt:A]` when creating composite layers

## keyd Debugging

**Essential tools**:
- `sudo keyd monitor` - Shows exact key names keyd detects (e.g., `leftbrace` vs `[`)
- `sudo keyd listen` - Shows layer transitions (`+alt`, `+shift`, `+alt+shift`)
- `cat -v` in terminal - Shows escape sequences actually received by applications

**Common issues**:
- Always check the official documentation for syntax examples - web search results can be outdated
- Some composite layers may not work as expected - test with simple output first
- Remember to restart keyd after config changes: `sudo systemctl restart keyd`

## Hyprland + keyd Integration

When using keyd for kernel-level remapping, you must unbind those keys in Hyprland:

```
# Unbind Super+W and Super+T - keyd handles them at kernel level
unbind = SUPER, W
unbind = SUPER, T
unbind = SUPER, LEFT
unbind = SUPER, RIGHT
unbind = SUPER, UP
unbind = SUPER, DOWN
```

This prevents conflicts where both keyd and Hyprland try to handle the same key combination.

## Successful Remapping Results

### Tab Management
- Super+T → New tab (Ctrl+T)
- Super+W → Close tab (Ctrl+W)
- Super+L → Focus location bar/command line (Ctrl+L)
- Alt+Shift+[ → Previous tab (Ctrl+Shift+Tab via macro)
- Alt+Shift+] → Next tab (Ctrl+Tab via macro)

### Text Navigation
- Super+Left → Start of line (Home)
- Super+Right → End of line (End)
- Super+Up → Start of document (Ctrl+Home)
- Super+Down → End of document (Ctrl+End)
- Super+Backspace → Delete word left (Ctrl+Backspace)

### Text Selection
- Super+Shift+Left → Select to start of line (Shift+Home)
- Super+Shift+Right → Select to end of line (Shift+End)
- Super+Shift+Up → Select to start of document (Ctrl+Shift+Home)
- Super+Shift+Down → Select to end of document (Ctrl+Shift+End)

## chezmoi Setup Process

The repository includes automated setup scripts:
- `run_once_enable-keyd.sh` - Installs keyd config and enables service (runs once on new machines)
- `run_onchange_*.sh` - Scripts that re-run when their content changes
- Templates (`.tmpl` files) - Use Go template syntax for cross-platform configs

**Best practices**:
- Test templates with `chezmoi execute-template < file.tmpl`
- Always run `chezmoi diff` before `chezmoi apply`
- Use `run_onchange_` prefix for scripts that should re-run after updates
- Use `run_once_` prefix for one-time setup tasks

## Tmux Clipboard over SSH: Built-in vs Custom Scripts

**Date**: 2025-11-08

**Problem**: Needed clipboard integration in tmux over SSH to copy text to local system clipboard using OSC52.

**What Didn't Work**:
- **Custom OSC52 script with `copy-pipe-and-cancel`**: Script generated correct OSC52 sequences but they didn't reach the terminal when called via tmux's `copy-pipe`
- **DCS passthrough wrapper**: Added tmux DCS passthrough (`\033Ptmux;\033...`) to the script, but piped output still didn't reach terminal
- **Output to /dev/tty**: Attempted to redirect script output to `/dev/tty`, but file descriptor was not available in copy-pipe context
- **Output to stderr**: Tried sending OSC52 to stderr instead of stdout, still no effect

**What Worked**: **Tmux 3.3+ built-in OSC52 support**

**Solution**:
```tmux
# Enable tmux's native clipboard support
set -g set-clipboard on
set -ag terminal-features ',*:clipboard'

# Use native copy bindings (no custom script)
bind -T copy-mode-vi y send-keys -X copy-selection-and-cancel
bind -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-selection-and-cancel
bind -T copy-mode MouseDragEnd1Pane send-keys -X copy-selection-and-cancel
```

**Key Insights**:
- Tmux 3.3+ has built-in OSC52 support and handles clipboard automatically when `set-clipboard on` is enabled
- Custom scripts called via `copy-pipe` cannot output OSC52 sequences to the terminal - their stdout goes to tmux's internal buffer, not to the terminal emulator
- When using `copy-selection-and-cancel` instead of `copy-pipe-and-cancel`, tmux itself sends the OSC52 sequence directly to the terminal
- No custom script is needed - tmux handles the OSC52 encoding and passthrough internally
- The `terminal-features` setting tells tmux that the terminal supports clipboard operations

**Debugging Process**:
1. Created isolated tests to verify each component:
   - Terminal OSC52 support (direct printf) - ✓ worked
   - Tmux DCS passthrough (direct printf in tmux) - ✓ worked
   - Script output format (correct escape sequences) - ✓ correct
   - Tmux bindings (calling the script) - ✓ configured
   - Script via pipe (echo | script) - ✗ failed
   - Tmux built-in clipboard (`copy-selection-and-cancel`) - ✓ worked

2. Key diagnostic: `tmux load-buffer` (which also uses tmux's internal clipboard) failed, but `copy-selection-and-cancel` succeeded - this revealed that tmux's built-in clipboard integration was working

**Related Files**:
- `dot_config/tmux/tmux.conf` - Clipboard bindings
- `dot_config/tmux/scripts/executable_osc52-copy.sh` - No longer needed, can be removed

**Terminal Compatibility**:
- Ghostty: ✓ Full OSC52 support
- iTerm2: ✓ Full OSC52 support
- Alacritty: ✓ Full OSC52 support
- WezTerm: ✓ Full OSC52 support

## Walker DMenu Mode Breaks After Reboot (RESOLVED)

**Date**: 2025-11-12 (Resolved same day)

**Problem**: Omarchy menu submenus (Style, Learn, Trigger, etc.) would fail to appear after system reboot.

**Root Cause**: Walker service and elephant processes get into a bad state after reboot, causing dmenu mode to become non-responsive. Not a bug in walker itself - just needs clean restart after boot.

**Symptoms**:
- Main Omarchy menu works (uses regular walker, not dmenu)
- ALL submenus fail after reboot (they use `walker --dmenu`)
- `make restart-walker` temporarily fixes the issue
- Problem recurs after next reboot

**Solution**: Automatic walker/elephant restart on login

Implemented in `dot_config/hypr/autostart.conf`:
```bash
# Fix walker dmenu mode by ensuring clean start after boot
exec-once = pkill walker; pkill elephant
```

**How it works**:
1. On Hyprland startup, kills any existing walker/elephant processes
2. Walker/elephant restart automatically when first invoked (via omarchy-launch-walker)
3. Fresh start ensures dmenu mode works correctly

**Manual fix** (if issue occurs mid-session):
```bash
make restart-walker
```

**Key Insights**:
- Walker dmenu mode IS functional - it just needs clean start after boot
- Testing from terminal appears to "hang" because walker waits for GUI interaction (selecting from menu)
- The walker gapplication-service can persist in bad state across reboots
- Simple kill/restart on login prevents the issue entirely

**Related Files**:
- `dot_config/hypr/autostart.conf:5` - Permanent fix implementation
- `~/.local/share/omarchy/bin/omarchy-menu:36` - Calls `omarchy-launch-walker --dmenu`
- `~/.local/share/omarchy/bin/omarchy-launch-walker:13` - Launches walker
- `Makefile:79` - `make restart-walker` target for manual fix

## keyd Removal: Conflicts with Hyprland and Walker (2025-11-12)

**Problem**: 
- Super+Shift+[ and Super+Shift+] shortcuts stopped working
- Omarchy menu submenus not appearing when clicked

**Root Causes**:
1. **Hyprland Key Swap Conflict**: Hyprland was configured to swap Alt/Super keys, but keyd was mapping `leftmeta` (Super) to activate layers. This caused keyd to receive Alt when Super was pressed, breaking the layer activation.
2. **Walker Service State**: The Omarchy menu (walker) was in a bad state, causing submenus to not appear. This was unrelated to keyd but discovered during troubleshooting.

**Solution**: 
- **Removed keyd entirely** - No longer needed since Caps Lock is already mapped to Control at the system level
- **Restarted walker** - Fixed submenu issues with `make restart-walker` or `pkill walker`

**Key Insights**:
- keyd and compositor-level key remapping (like Hyprland's input config) can conflict
- When using Hyprland's alt/super swap, keyd needs to map `leftalt` instead of `leftmeta` to activate layers
- Walker/elephant services can get into bad states and need occasional restarts
- The `make restart-walker` target (already existed) is the proper fix for walker issues
- Troubleshooting window rules (nofocus, stayfocused, etc.) was a red herring - the issue was walker state, not Hyprland window rules

**What Didn't Work**:
- Adding `stayfocused` window rules to override Omarchy defaults
- Commenting out the `nofocus` rule in Omarchy's `windows.conf`
- Changing keyd to use `leftalt` instead of `leftmeta`
- Various keyd macro syntaxes: `macro(C-S-tab)`, `leftcontrol-leftshift-tab`, etc.

**Proper Fix**:
- Remove keyd configuration (unnecessary with Caps Lock → Control mapping)
- Use `make restart-walker` when Omarchy menus misbehave
- Let Hyprland handle all keyboard shortcuts natively

**Related Commits**:
- `a0e4a86` - Remove keyd configuration
