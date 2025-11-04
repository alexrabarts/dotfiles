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
