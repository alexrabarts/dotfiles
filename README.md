# Dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/) for macOS and Linux.

A comprehensive development environment featuring zsh with Powerlevel10k, Neovim with LazyVim, tmux with custom status modules, and cross-platform utility scripts.

## Features

- **Shell Environment**: Zsh with Powerlevel10k theme, zinit plugin manager, and smart PATH management
- **Editor**: Neovim configured with LazyVim, optimized for Go, TypeScript, and general development
- **Terminal Multiplexer**: Tmux with Catppuccin theme and custom status line showing git, system metrics
- **Utility Scripts**: Go version installer, PostgreSQL connection manager, keyboard backlight controls
- **Package Management**: Homebrew (macOS) and pacman (Arch Linux) with declarative package lists
- **Security**: Age encryption for sensitive files (.env, .pgpass)
- **Cross-Platform**: Conditional configuration for macOS and Linux with architecture detection

## Quick Start

### Prerequisites

Install chezmoi and age before proceeding:

**macOS**
```bash
brew install chezmoi age
```

**Linux (Arch)**
```bash
sudo pacman -S chezmoi age
```

For other distributions, see [chezmoi installation](https://www.chezmoi.io/install/) and [age installation](https://github.com/FiloSottile/age#installation).

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/alexrabarts/dotfiles.git ~/.local/share/chezmoi
   cd ~/.local/share/chezmoi
   ```

2. **Run the installer**
   ```bash
   make install
   ```

   This will:
   - Verify prerequisites are installed
   - Prompt for your age encryption key (retrieve from 1Password or backup)
   - Apply all dotfiles to your home directory
   - Decrypt and configure encrypted files
   - Install tmux plugins via TPM

3. **Install packages** (optional but recommended)
   ```bash
   make install-packages
   ```

   This installs all tools from `Brewfile` (macOS) or `pkglist.txt` (Linux).

4. **Restart your shell**
   ```bash
   exec zsh
   ```

### Alternative Installation Methods

**With 1Password CLI** (if configured and authenticated)
```bash
mkdir -p ~/.config/age
op document get "age-chezmoi-key" > ~/.config/age/key.txt
chmod 600 ~/.config/age/key.txt
cd ~/.local/share/chezmoi
chezmoi apply
```

**Manual Setup**
```bash
# Clone repository
git clone https://github.com/alexrabarts/dotfiles.git ~/.local/share/chezmoi

# Setup age key manually
mkdir -p ~/.config/age
# Paste your age private key (AGE-SECRET-KEY-...) into:
vim ~/.config/age/key.txt
chmod 600 ~/.config/age/key.txt

# Apply dotfiles
cd ~/.local/share/chezmoi
chezmoi apply
```

## What's Included

### Shell Configuration

**Zsh** with Powerlevel10k prompt theme
- **Zinit** plugin manager with syntax highlighting and completions
- **Zoxide** for smart directory jumping (aliased to `cd`)
- **Atuin** for searchable shell history
- PATH management with duplicate prevention
- Cross-platform conditionals for macOS and Linux
- Chezmoi aliases: `cz`, `cze`, `czd`, `czap`, `ca`

### Neovim Configuration

**LazyVim** distribution with sensible defaults
- Language support: Go, TypeScript, Lua, Python, Bash, Rust
- **Treesitter** for advanced syntax highlighting
- **LSP** configurations with Mason auto-installer
- **Catppuccin Mocha** colorscheme
- Git integration: Neogit and Gitsigns
- Custom keymaps with `<Space>` leader key

See [dot_config/nvim/README.md](dot_config/nvim/README.md) for details.

### Tmux Configuration

**Catppuccin Mocha** theme with custom status line
- **Custom status modules**:
  - Git branch and status
  - System load and CPU usage
  - Memory usage
  - Disk usage for current directory
  - Hostname
- Mouse support with smart scrolling
- Vi-mode keybindings for copy mode
- Window/pane navigation with Option/Alt keys
- **Prefix key**: `Ctrl+Space`

See [dot_config/tmux/CLAUDE.md](dot_config/tmux/CLAUDE.md) for details.

### Utility Scripts

Located in `~/bin/` after installation:

- **go-install**: Install specific Go versions from official releases
  - Auto-detects OS and architecture
  - Usage: `go-install 1.21.5`

- **pg**: Smart PostgreSQL connection manager
  - Lists databases from `~/.pgpass`
  - Quick connect: `pg database-name`
  - Includes zsh tab completion

- **kbd-backlight-***: Keyboard backlight controls for MacBooks on Linux
  - Auto-dim on inactivity
  - Manual brightness controls

- **capslock-to-control**: Remap Caps Lock to Control (macOS)

See [bin/CLAUDE.md](bin/CLAUDE.md) for complete documentation.

### Package Lists

- **Brewfile** (macOS): Declarative package list for Homebrew
- **pkglist.txt** (Arch Linux): List of packages for pacman

### System Configuration

- **keyd**: Keyboard remapping for Linux (Caps Lock to Control/Escape)
- **systemd**: Custom service configurations
- **udev rules**: MTP device access
- **T2 chip support**: Keyboard and suspend fixes for MacBooks running Linux

## Daily Usage

### Common Commands

```bash
# Edit a managed file (opens in $EDITOR, prompts to apply)
chezmoi edit ~/.zshrc

# Preview what would change before applying
chezmoi diff

# Apply changes
chezmoi apply

# Quick apply and reload shell (using czap alias)
czap

# Add a new file to chezmoi management
chezmoi add ~/.config/newfile

# Add an encrypted file
chezmoi add --encrypt ~/.env
```

### Useful Aliases

Defined in `~/.zshrc`:

```bash
cz      # chezmoi
cze     # chezmoi edit
czd     # chezmoi diff
czap    # chezmoi apply && exec zsh (apply and reload shell)
ca      # chezmoi apply
ta      # tmux attach
```

### Makefile Targets

```bash
make help                 # Show all available targets
make install              # Full setup (check prereqs, setup age, apply dotfiles, tmux plugins)
make install-packages     # Install packages (Homebrew or pacman)
make install-tmux-plugins # Install tmux plugins via TPM
make check-prerequisites  # Verify chezmoi and age are installed
make setup-age            # Setup age encryption only
make init-chezmoi         # Initialize chezmoi with this repo (for development)
```

## Working with Encrypted Files

Files matching `private_*` or `encrypted_*` patterns are encrypted with age.

**Current encrypted files:**
- `~/.env` - Environment variables
- `~/.pgpass` - PostgreSQL connection credentials

**Add a new encrypted file:**
```bash
chezmoi add --encrypt ~/.sensitive-file
```

**Edit an encrypted file:**
```bash
chezmoi edit ~/.env
```

Chezmoi automatically decrypts on edit and re-encrypts on apply.

## Working with Templates

Files ending in `.tmpl` are Go templates processed by chezmoi. They support conditional logic based on OS and architecture:

```go
{{- if eq .chezmoi.os "darwin" -}}
# macOS-specific configuration
{{- end }}

{{- if eq .chezmoi.os "linux" -}}
# Linux-specific configuration
{{- end }}
```

**Test template rendering:**
```bash
chezmoi execute-template < dot_zshrc.tmpl
```

**Preview rendered output:**
```bash
chezmoi cat ~/.zshrc
```

## Package Management

### macOS (Homebrew)

Packages are defined in `Brewfile`.

**Export currently installed packages:**
```bash
brew bundle dump --force --describe
```

**Install packages from Brewfile:**
```bash
make install-packages
# or
brew bundle install
```

### Linux (Arch)

Packages are listed in `dot_config/pkglist.txt`.

**Export currently installed packages:**
```bash
pacman -Qqe > ~/.config/pkglist.txt
chezmoi add ~/.config/pkglist.txt
```

**Install packages from list:**
```bash
make install-packages
# or
sudo pacman -S --needed - < ~/.config/pkglist.txt
```

## Repository Structure

```
.
├── bin/                          # Utility scripts (→ ~/bin/)
├── dot_config/                   # Config files (→ ~/.config/)
│   ├── nvim/                     # Neovim configuration
│   ├── tmux/                     # Tmux configuration
│   ├── alacritty/                # Alacritty terminal config
│   ├── ghostty/                  # Ghostty terminal config
│   └── hypr/                     # Hyprland config
├── dot_ssh/                      # SSH configuration
├── private_dot_claude/           # Claude AI agent configurations
├── Brewfile                      # macOS packages (Homebrew)
├── dot_config/pkglist.txt        # Linux packages (pacman)
├── dot_zshrc.tmpl                # Main zsh config (templated)
├── dot_zprofile                  # Zsh login config
├── Makefile                      # Setup automation
└── run_once_*.sh                 # One-time setup scripts
```

### File Naming Conventions

Chezmoi uses special prefixes to determine file behavior:

- `dot_` → `.` (e.g., `dot_zshrc` → `~/.zshrc`)
- `private_` → Encrypted with age
- `encrypted_` → Encrypted with age
- `.tmpl` → Processed as Go template
- `executable_` → Made executable
- `run_once_` → Run once during `chezmoi apply`
- `run_onchange_` → Run when file content changes
- `symlink_` → Created as symlink

## Troubleshooting

### Age Encryption Errors

**Error: "age: error: decrypting file: no identity matched"**

Your age private key is missing or incorrect.

**Solution:**
```bash
# Using 1Password CLI
op document get "age-chezmoi-key" > ~/.config/age/key.txt
chmod 600 ~/.config/age/key.txt

# Or manually paste key
mkdir -p ~/.config/age
# Paste AGE-SECRET-KEY-... into the file
chmod 600 ~/.config/age/key.txt
```

### Changes Not Applying

**Issue**: Files not updating after `chezmoi apply`

**Solution:**
```bash
# Check what would change
chezmoi diff

# Apply with verbose output
chezmoi apply -v

# Check chezmoi status
chezmoi doctor

# Force re-add a file if needed
chezmoi add --force ~/.zshrc
```

### Shell Configuration Not Loading

**Issue**: New shell doesn't have expected configuration

**Solution:**
```bash
# Verify files were applied
ls -la ~/.zshrc ~/.zprofile

# Source configuration manually
source ~/.zshrc

# Or restart shell
exec zsh

# Check for syntax errors
zsh -n ~/.zshrc
```

### Tmux Plugins Not Loading

**Issue**: Tmux doesn't show custom theme or plugins

**Solution:**
```bash
# Install tmux plugins automatically
make install-tmux-plugins

# Or manually install TPM and plugins
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
~/.tmux/plugins/tpm/bin/install_plugins

# Or inside tmux, install plugins interactively
# Press: Ctrl+Space then Shift+I (capital I)

# Reload tmux configuration
tmux source ~/.config/tmux/tmux.conf
```

### Neovim Plugin Issues

**Issue**: Neovim plugins missing or not working

**Solution:**
```bash
# Open Neovim and check Lazy plugin manager
nvim
:Lazy

# Sync all plugins (install/update/clean)
:Lazy sync

# Check for errors
:checkhealth
```

### PATH Issues

**Issue**: Commands not found or wrong version being used

**Solution:**
```bash
# Check current PATH
echo $PATH

# Verify PATH order in ~/.zshrc
# User bin directories should come first:
# ~/bin → ~/.local/bin → ~/go/bin → system paths

# Reload shell
exec zsh

# Check which version is being used
which <command>
```

### Platform-Specific Issues

**macOS - Homebrew not in PATH**

Ensure `~/.zprofile` is being sourced (login shells):
```bash
cat ~/.zprofile
# Should contain: eval "$(/opt/homebrew/bin/brew shellenv)"
```

**macOS - Caps Lock remap not working**

The `capslock-to-control` script may need manual execution:
```bash
~/bin/capslock-to-control
```

**Linux - Keyboard remapping not working**

Check keyd service status:
```bash
sudo systemctl status keyd

# Restart if needed
sudo systemctl restart keyd
```

**Linux - Locale issues**

Generate the en_GB.UTF-8 locale:
```bash
sudo locale-gen en_GB.UTF-8
```

## Documentation

- **README.md** - This file: setup, features, and usage guide
- **CHANGELOG.md** - Version history and release notes
- **CLAUDE.md** - Detailed documentation for AI agents (architecture, workflows, patterns)
- **bin/CLAUDE.md** - Documentation of utility scripts
- **dot_config/tmux/CLAUDE.md** - Tmux configuration details
- **dot_config/nvim/README.md** - Neovim setup guide

## Development

### Making Changes

```bash
# Work directly in the source directory
cd ~/.local/share/chezmoi

# Edit files
vim dot_zshrc.tmpl

# Preview changes
chezmoi diff

# Test apply in dry-run mode
chezmoi apply --dry-run

# Apply changes
chezmoi apply

# Commit changes
git add .
git commit -m "Description of changes"
git push
```

### Testing on a New Machine

```bash
# Use a Docker container for testing
docker run -it --rm ubuntu:latest bash

# Install prerequisites
apt update && apt install -y git curl

# Install chezmoi
sh -c "$(curl -fsLS get.chezmoi.io)"

# Clone and test
git clone <repo-url> ~/.local/share/chezmoi
cd ~/.local/share/chezmoi
make install
```

## License

MIT

## Author

Alex Rabarts
