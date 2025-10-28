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
