# Tmux Configuration Documentation

This directory contains tmux configuration and custom status line scripts for a rich terminal multiplexer experience.

## Overview

The tmux configuration features:
- **Catppuccin Mocha** theme with custom status line
- **Custom status modules** showing git, CPU, memory, disk, load, and hostname
- **Vim-style keybindings** for copy mode
- **Mouse support** with smart scrolling
- **Intuitive navigation** using Option/Alt modifier keys
- **TPM (Tmux Plugin Manager)** for plugin management

## File Structure

```
dot_config/tmux/
├── tmux.conf              # Main tmux configuration
└── scripts/               # Custom status line scripts
    ├── git-brief.sh       # Git repository status
    ├── cpu-brief.sh       # CPU usage percentage
    ├── memory-brief.sh    # Memory usage percentage
    ├── load-brief.sh      # System load average
    ├── disk-brief.sh      # Disk usage for current directory
    └── host-brief.sh      # Hostname display
```

## Configuration Details

### Prefix Key

The default prefix (`Ctrl-b`) is changed to `Ctrl-Space` for easier access:

```tmux
unbind C-b
set -g prefix C-Space
bind C-space send-prefix
```

**Usage**: Press `Ctrl-Space` followed by tmux commands.

### Window Navigation

Multiple methods for switching between windows:

**Option/Alt + Number**: Direct window selection
- `Alt-1` through `Alt-9` → Select windows 1-9
- `Alt-0` → Select window 10

**Option/Alt + Brackets**: Sequential navigation
- `Alt-[` or `Alt-{` → Previous window
- `Alt-]` or `Alt-}` → Next window

**Ctrl + Tab**: Browser-style navigation
- `Ctrl-Tab` → Next window
- `Ctrl-Shift-Tab` → Previous window

### Session Navigation

**Option/Alt + Backtick**:
- `Alt-\`` → Next session
- `Alt-~` (Shift-\`) → Previous session

### Pane Management

**Splitting**:
- `Prefix + |` → Split horizontally (side by side)
- `Prefix + -` → Split vertically (top and bottom)
- `Prefix + %` → Split horizontally (tmux default)
- `Prefix + "` → Split vertically (tmux default)

All splits open in the current working directory.

**Resizing** (no prefix required):
- `Alt--` → Shrink pane left
- `Alt-=` → Expand pane right
- `Alt-_` (Shift-minus) → Shrink pane up
- `Alt-+` (Shift-equals) → Expand pane down

**Pane Navigation**: Handled by `vim-tmux-navigator` plugin
- Seamless navigation between vim splits and tmux panes
- Use vim navigation keys (`Ctrl-h/j/k/l`)

### Copy Mode

**Vi-mode keybindings**:
- `Space` → Begin selection
- `v` → Begin selection (explicit)
- `Ctrl-v` → Rectangle selection
- `y` → Copy selection and exit
- `Enter` → Copy selection and exit

**Scrollback**:
- Mouse wheel up automatically enters copy mode
- Buffer size: 10,000 lines
- Search with `/` (forward) or `?` (backward)

### Clipboard Support (OSC52 over SSH)

**Overview**:
The tmux configuration uses OSC52 escape sequences for clipboard support, which allows copying to your local clipboard even when connected to a remote machine via SSH. This works without requiring any clipboard tools (xsel, xclip, pbcopy) on the remote system.

**How It Works**:
1. When you copy text (via mouse selection or `y` key), tmux pipes it to `~/.config/tmux/scripts/osc52-copy.sh`
2. The script encodes the text in base64 and wraps it in an OSC52 escape sequence
3. The escape sequence is sent through the SSH connection to your local terminal
4. Your local terminal (Ghostty, iTerm2, Alacritty, etc.) receives the OSC52 sequence and copies the text to your system clipboard

**Supported Terminals**:
- Ghostty (full support)
- iTerm2 (macOS)
- Alacritty
- WezTerm
- kitty
- Windows Terminal
- Most modern terminals

**Copy Methods**:
- **Mouse selection**: Click and drag to select text - automatically copies on release
- **Keyboard in copy mode**: Press `y` after selecting text with `v`
- **Double-click**: Selects and copies a word
- **Triple-click**: Selects and copies a line

**Limitations**:
- Maximum clipboard size: 100KB (most terminals support this limit)
- Requires terminal to support OSC52 escape sequences
- Some older terminals may not support OSC52

**Configuration Details**:
```tmux
# Enable OSC52 support
set -g set-clipboard on
set -ag terminal-features ',*:clipboard'

# Bind copy operations to OSC52 script
bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "~/.config/tmux/scripts/osc52-copy.sh"
bind -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "~/.config/tmux/scripts/osc52-copy.sh"
```

**Troubleshooting**:
- If clipboard doesn't work, verify your terminal supports OSC52
- Check script is executable: `ls -la ~/.config/tmux/scripts/osc52-copy.sh`
- Test script directly: `echo "test" | ~/.config/tmux/scripts/osc52-copy.sh`
- For Ghostty, ensure you're using a recent version (has native OSC52 support)

### Visual Features

**Colors**: 24-bit true color support enabled

**Window Indexing**: Starts at 1 (not 0) for easier keyboard access

**Auto-renumbering**: Windows automatically renumber when one is closed

**Terminal Titles**: Set dynamically to show hostname and last 2 path components
- Format: `hostname: parent/current`
- Example: `macbook: repos/dotfiles`

### Plugins

Managed by TPM (Tmux Plugin Manager):

**Core Plugins**:
- `tmux-plugins/tpm` - Plugin manager itself
- `tmux-plugins/tmux-sensible` - Sensible default settings
- `christoomey/vim-tmux-navigator` - Seamless vim/tmux navigation
- `catppuccin/tmux` - Base Catppuccin theme

**Installing Plugins**:
```bash
# Inside tmux, press:
Ctrl-Space + Shift-I  # (capital I)

# This installs all plugins listed in tmux.conf
```

**Updating Plugins**:
```bash
# Inside tmux, press:
Ctrl-Space + U
```

## Status Line

### Layout

The status line is highly customized with these modules (left to right):

```
[Session Name] [Current Directory] [Git] [Load] [CPU] [Memory] [Disk] [Hostname]
```

**Left Side**:
- Session name with custom styling

**Right Side** (modules shown as colored pills):
- Current directory (last 2 components)
- Git status (if in repository)
- System load
- CPU percentage
- Memory percentage
- Disk usage
- Hostname

### Status Scripts

All scripts are in `~/.config/tmux/scripts/` and are executed by tmux to populate the status line.

#### git-brief.sh

**Purpose**: Shows git repository information for current pane directory

**Display Format**:
```
󰊢 ⎇ branch-name ↑·2 ↓·1 ✚ 3 ∆ 2 … 1
```

**Symbols**:
- `󰊢` - Git icon (Nerd Font)
- `⎇` - Branch symbol
- `↑·N` - N commits ahead of upstream
- `↓·N` - N commits behind upstream
- `✚ N` - N staged files
- `∆ N` - N unstaged (modified) files
- `… N` - N untracked files

**Colors**: Teal pill (`#94e2d5` - Catppuccin Teal)

**Behavior**:
- Only displays when pane is inside a git repository
- Shows "detached" if in detached HEAD state
- Updates automatically as you navigate directories
- Gracefully handles missing upstream branch

#### cpu-brief.sh

**Purpose**: Shows current CPU usage percentage

**Display Format**:
```
 42%
```

**Color-coding**:
- Green (`#a6e3a1`): 0-59% (normal)
- Yellow (`#f9e2af`): 60-84% (moderate)
- Red (`#f38ba8`): 85-100% (high)

**Measurement**:
- Reads `/proc/stat` twice with 0.1s delay
- Calculates CPU usage between samples
- Rounds to nearest integer percentage

**Update Frequency**: Controlled by tmux `status-interval` setting

#### memory-brief.sh

**Purpose**: Shows current memory usage percentage

**Display Format**:
```
󰍛 73%
```

**Symbol**: `󰍛` - Memory chip icon (Nerd Font)

**Color-coding**:
- Green (`#a6e3a1`): 0-64% (normal)
- Yellow (`#f9e2af`): 65-84% (moderate)
- Red (`#f38ba8`): 85-100% (high)

**Measurement**:
- Reads `/proc/meminfo`
- Calculates: `(MemTotal - MemAvailable) / MemTotal`
- Uses `MemAvailable` for accurate "used" calculation (includes caches that can be freed)

#### load-brief.sh

**Purpose**: Shows system load average

**Display Format**:
```
󰊚 1.23
```

**Symbol**: `󰊚` - Gauge icon (Nerd Font)

**Color-coding**:
- Green (`#a6e3a1`): Normal load (< CPU cores)
- Yellow (`#f9e2af`): Moderate load (≥ CPU cores, < 2x cores)
- Red (`#f38ba8`): High load (≥ 2x CPU cores)

**Measurement**:
- Shows 1-minute load average from `/proc/loadavg`
- Normalizes by CPU core count for color selection
- Example: On 4-core system, 4.0 load = yellow, 8.0+ = red

#### disk-brief.sh

**Purpose**: Shows disk usage for filesystem containing current pane directory

**Display Format**:
```
 87%
```

**Symbol**: `` - Disk icon (Nerd Font)

**Color-coding**:
- Green (`#a6e3a1`): 0-79% (normal)
- Yellow (`#f9e2af`): 80-89% (moderate)
- Red (`#f38ba8`): 90-100% (critical)

**Measurement**:
- Uses `df` to get filesystem stats
- Shows usage percentage for the filesystem containing current directory
- Updates as you navigate to different filesystems

**Behavior**:
- Smart handling of paths (resolves symlinks)
- Falls back gracefully if path doesn't exist
- Useful for monitoring different mount points

#### host-brief.sh

**Purpose**: Shows current hostname

**Display Format**:
```
󰇅 hostname
```

**Symbol**: `󰇅` - Computer/server icon (Nerd Font)

**Color**: Purple pill (`#cba6f7` - Catppuccin Mauve)

**Behavior**:
- Shows short hostname (without domain)
- Useful when working with multiple remote sessions
- Always visible (no conditional display)

### Customizing Status Line

The status line is configured in `tmux.conf`:

```tmux
set -g status-right "#{E:@catppuccin_status_application}"
set -ag status-right '#(~/.config/tmux/scripts/git-brief.sh "#{pane_current_path}")'
set -ag status-right '#(~/.config/tmux/scripts/load-brief.sh)'
# ... more modules
```

**To modify**:
1. Edit `tmux.conf`
2. Reload config: `tmux source ~/.config/tmux/tmux.conf`
3. Or restart tmux session

**To add a module**:
1. Create script in `scripts/` directory
2. Make it executable: `chmod +x scripts/my-module.sh`
3. Add to status line: `set -ag status-right '#(~/.config/tmux/scripts/my-module.sh)'`
4. Follow the color scheme format (see existing scripts)

**Module Format**:
```bash
# Output tmux color codes + text + reset
printf '#[fg=#color]#[fg=#fg,bg=#bg] Icon #[fg=#cdd6f4,bg=#313244] Text #[fg=#313244]'
```

## Catppuccin Theme Customization

The configuration heavily customizes the Catppuccin theme:

**Theme Variant**: Mocha (dark theme)

**Customizations**:
- Window status format (custom pills design)
- Separator styles (seamless powerline)
- Status background (transparent)
- Application text showing last 2 path components

**Custom Window Format**:
```tmux
# Inactive windows: gray pill
#[fg=#313244,bg=#181825]#[fg=#cdd6f4,bg=#313244] #I #W #[...]

# Active window: purple pill
#[fg=#45475a,bg=#181825]#[fg=#11111b,bg=#cba6f7] #I #[fg=#cdd6f4,bg=#45475a] #W #[...]
```

**Colors Used** (Catppuccin Mocha):
- `#181825` - Mantle (background)
- `#313244` - Surface0 (inactive window bg)
- `#45475a` - Surface1 (active window bg)
- `#cdd6f4` - Text (foreground)
- `#11111b` - Crust (active window number bg)
- `#cba6f7` - Mauve (active window accent)
- `#94e2d5` - Teal (git status)
- `#a6e3a1` - Green (good metrics)
- `#f9e2af` - Yellow (warning metrics)
- `#f38ba8` - Red (critical metrics)

## Usage Examples

### Starting Tmux

```bash
# Start new session
tmux

# Start named session
tmux new -s work

# Attach to existing session
tmux attach
# or use alias
ta
```

### Managing Windows

```bash
# Create new window
Ctrl-Space c

# Rename window
Ctrl-Space ,

# Close window
Ctrl-Space &
# or just: exit

# Switch windows
Alt-1  # Window 1
Alt-2  # Window 2
# ... etc
```

### Managing Panes

```bash
# Split horizontally (side by side)
Ctrl-Space |

# Split vertically (top/bottom)
Ctrl-Space -

# Resize panes
Alt-=  # Expand right
Alt--  # Shrink left
Alt-+  # Expand down
Alt-_  # Shrink up

# Close pane
Ctrl-d  # or: exit
```

### Copy Mode

```bash
# Enter copy mode
Ctrl-Space [

# Navigate (vi keys)
h j k l       # Move cursor
Ctrl-f/b      # Page down/up
g / G         # Top / Bottom

# Search
/pattern      # Search forward
?pattern      # Search backward
n / N         # Next/previous match

# Copy
v             # Start selection
Ctrl-v        # Rectangle selection
y             # Copy and exit

# Paste
Ctrl-Space ]
```

### Session Management

```bash
# Create new session
Ctrl-Space :new -s session-name

# Switch sessions
Alt-`         # Next session
Alt-~         # Previous session
Ctrl-Space s  # Session list

# Detach from session
Ctrl-Space d

# Kill session
Ctrl-Space :kill-session
```

## Troubleshooting

### Plugins Not Loading

**Problem**: Catppuccin theme or other plugins not working

**Solution**:
```bash
# Install TPM
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Inside tmux, install plugins
Ctrl-Space + Shift-I
```

### Status Line Not Showing

**Problem**: Custom status modules not appearing

**Solution**:
```bash
# Check if scripts are executable
ls -la ~/.config/tmux/scripts/
# All should be -rwxr-xr-x

# Make executable if needed
chmod +x ~/.config/tmux/scripts/*.sh

# Reload tmux config
tmux source ~/.config/tmux/tmux.conf
```

### Colors Look Wrong

**Problem**: Colors appear incorrect or washed out

**Solution**:
```bash
# Check terminal supports 24-bit color
echo $TERM
# Should be: xterm-256color, tmux-256color, or similar

# Test true color support
printf "\x1b[38;2;255;100;0mTRUECOLOR\x1b[0m\n"
# Should show orange text

# Ensure terminal emulator supports true color
# Alacritty, Ghostty, iTerm2: ✓
# Some older terminals: ✗
```

### Icons/Symbols Not Showing

**Problem**: Boxes or missing characters instead of icons

**Solution**:
- Install a Nerd Font (e.g., JetBrains Mono Nerd Font)
- Configure terminal emulator to use Nerd Font
- Fonts included in Brewfile/pkglist.txt: `font-jetbrains-mono-nerd-font`

### Keybindings Not Working

**Problem**: Alt/Option key shortcuts don't work (especially on macOS)

**Solution for macOS**:
- **iTerm2**: Preferences → Profiles → Keys → Left/Right Option key → "Esc+"
- **Alacritty**: Already configured in `dot_config/alacritty/alacritty.toml`
- **Ghostty**: Already configured in `dot_config/ghostty/config`

### Status Scripts Slow

**Problem**: Tmux feels laggy or status line updates slowly

**Solution**:
```bash
# Adjust update interval in tmux.conf
set -g status-interval 5  # Default: 5 seconds (increase to reduce updates)

# Check if scripts are hanging
~/.config/tmux/scripts/cpu-brief.sh  # Should return immediately
~/.config/tmux/scripts/git-brief.sh "$PWD"  # Test with current dir

# Optimize git script by excluding submodules or large repos
```

### Git Status Wrong

**Problem**: Git status shows incorrect information

**Solution**:
```bash
# Test script directly
cd /path/to/git/repo
~/.config/tmux/scripts/git-brief.sh "$PWD"

# Check git repository health
git status
git fsck

# Ensure script has correct permissions
chmod +x ~/.config/tmux/scripts/git-brief.sh
```

## Advanced Configuration

### Adjusting Status Update Frequency

In `tmux.conf`:
```tmux
# Update every 2 seconds (more responsive, higher CPU)
set -g status-interval 2

# Update every 10 seconds (less responsive, lower CPU)
set -g status-interval 10
```

### Changing Alert Thresholds

Edit individual scripts to adjust when colors change:

**Example** (`cpu-brief.sh`):
```bash
# Original
if (( usage >= 850 )); then     # 85%+: red
  bg_color="#f38ba8"
elif (( usage >= 600 )); then   # 60%+: yellow
  bg_color="#f9e2af"
fi

# More sensitive
if (( usage >= 700 )); then     # 70%+: red
  bg_color="#f38ba8"
elif (( usage >= 400 )); then   # 40%+: yellow
  bg_color="#f9e2af"
fi
```

### Disabling Modules

Comment out unwanted modules in `tmux.conf`:
```tmux
set -ag status-right '#(~/.config/tmux/scripts/git-brief.sh "#{pane_current_path}")'
# set -ag status-right '#(~/.config/tmux/scripts/load-brief.sh)'  # Disabled
set -ag status-right '#(~/.config/tmux/scripts/cpu-brief.sh)'
```

Then reload: `tmux source ~/.config/tmux/tmux.conf`

### Custom Key Bindings

Add to `tmux.conf`:
```tmux
# Custom bindings
bind-key r source-file ~/.config/tmux/tmux.conf \; display "Config reloaded!"
bind-key K kill-window
bind-key X kill-pane

# Application launchers
bind-key N new-window -n notes nvim ~/notes/
bind-key G new-window -n lazygit lazygit
```

## Related Documentation

- **CLAUDE.md** (root) - Overall repository architecture
- **README.md** - User-facing documentation
- **bin/CLAUDE.md** - Related utility scripts

## Resources

- [Tmux Documentation](https://github.com/tmux/tmux/wiki)
- [Catppuccin Tmux](https://github.com/catppuccin/tmux)
- [TPM - Tmux Plugin Manager](https://github.com/tmux-plugins/tpm)
- [Nerd Fonts](https://www.nerdfonts.com/) - For status line icons
