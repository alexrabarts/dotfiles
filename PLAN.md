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
# When Super is held, remap these keys
t = C-t
w = C-w
```

**Key insight**: The `[meta]` layer (not `meta.t` in `[main]`) is the correct syntax for remapping Super+key combinations.

**Hyprland config** (`dot_config/hypr/bindings.conf.tmpl`):
```
# Unbind Super+W and Super+T - keyd handles them at kernel level
unbind = SUPER, W
unbind = SUPER, T
bindd = SUPER, Q, Close window, killactive,
bindd = SUPER, D, Toggle floating, togglefloating,
```

### What Didn't Work

1. **wtype**: Unreliable - Super+W worked but Super+T was flaky
2. **ydotool with `bindd` (bind on press)**: SUPER still held down when ydotool sent Ctrl+T, creating SUPER+Ctrl+T conflict
3. **ydotool with `bindr` (bind on release)**: Only worked if you released SUPER very quickly - not natural UX
4. **ydotool with delays**: Hacky and still unreliable
5. **keyd with wrong syntax**: `meta.t = C-t` in `[main]` section didn't work - needed `[meta]` layer instead

### Files Modified

**keyd:**
- `keyd-config/default.conf` - Simple 2-line remapping in `[meta]` layer
- `run_once_enable-keyd.sh` - Auto-installs config to `/etc/keyd/` and enables service

**Hyprland:**
- `dot_config/hypr/bindings.conf.tmpl` - Unbind Super+W/T, keep Super+Q and Super+D

**Packages:**
- `dot_config/pkglist.txt` - Added `keyd` back, removed `ydotool`

### Setup on New Machine

The `run_once_enable-keyd.sh` script handles everything automatically:
1. Installs keyd config to `/etc/keyd/default.conf`
2. Enables and starts keyd service
3. No manual configuration needed

### Key Bindings

- **Super+T** → New tab (remapped to Ctrl+T by keyd)
- **Super+W** → Close tab (remapped to Ctrl+W by keyd)
- **Super+Q** → Close window (Hyprland native)
- **Super+D** → Toggle floating (moved from Super+T)
- **Super+Alt+Space** → Omarchy settings menu
- **Super+Space** → App launcher

All other Super key bindings pass through normally - keyd only touches T and W.

### Lessons Learned

- Userspace keystroke injection tools (wtype, ydotool) don't work well for modifier key remapping because the physical modifier is still pressed when synthetic keys are sent
- Kernel-level remapping (keyd, kmonad) is the proper solution for this use case
- keyd syntax is specific: use `[modifier]` layers, not `modifier.key` in `[main]`
- Always check the official documentation for syntax examples - web search results can be outdated
