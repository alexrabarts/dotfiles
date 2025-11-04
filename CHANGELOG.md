# Changelog

All notable changes to this dotfiles configuration will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Comprehensive documentation throughout the repository
  - Enhanced README.md with detailed setup, features, and troubleshooting
  - Created bin/CLAUDE.md documenting all utility scripts
  - Created dot_config/tmux/CLAUDE.md for tmux configuration
  - Enhanced dot_config/nvim/README.md with LazyVim details
  - Added CHANGELOG.md for tracking configuration changes

## [1.0.0] - 2024-11-04

### Added
- Claude AI agent configurations managed by chezmoi
  - Technical documentation writer agent
  - Prompt engineer agent
  - Multiple specialized agents for development workflows
- T2 MacBook support improvements
  - Improved suspend/resume handling for T2 keyboards
  - Keyboard fix installation script
  - S2idle sleep mode configuration
- macOS Caps Lock to Control remapping
  - Launch Agent for persistent remapping
  - `capslock-to-control` utility script
- Tmux navigation enhancements
  - Alt+bracket keys for window navigation
  - Ctrl+Tab window cycling
  - Pane resizing keybindings (Alt + -/=/+/_)
- Ghostty terminal configuration
  - Terminal type configuration for macOS
  - Custom keybindings and color scheme
- SSH server setup automation
  - systemd service configuration
  - Automatic startup scripts

### Changed
- Improved cross-platform support
  - macOS/Linux conditional configuration
  - Brewfile for macOS package management
  - Better OS detection in scripts
- Enhanced keyd configuration
  - macOS-style keyboard shortcuts on Linux
  - Super+T/W for tab/window operations
  - Alt+Shift for tab switching
  - Text navigation shortcuts (Super+arrows)

### Fixed
- Reverted problematic Ghostty CSI sequence configuration
- Reverted tmux Meta arrow navigation that caused conflicts
- Improved reliability of keyboard shortcuts using ydotool

### Removed
- Unstable keyboard shortcut implementations (wtype-based)

## [0.9.0] - 2024-10-26

### Added
- Tmux custom status line with system metrics
  - Git repository status module
  - CPU usage monitoring
  - Memory usage monitoring
  - Disk usage monitoring
  - Load average display
  - Hostname display
- Tmux Catppuccin Mocha theme customization
  - Custom window status format
  - Powerline-style separators
  - Color-coded system metrics (green/yellow/red)
- Keyboard backlight automation for Linux
  - Auto-dim on inactivity (15 second timeout)
  - Manual brightness controls (up/down/toggle)
  - kbdlightd daemon with systemd integration
- Neovim LazyVim configuration
  - LSP support for Lua, Go, TypeScript, Rust, Python, Bash
  - Mason for automatic LSP installation
  - Blink.cmp for fast completion
  - Treesitter for syntax highlighting
  - Neogit for git operations
  - TokyoNight colorscheme

### Changed
- Restructured Neovim configuration for maintainability
  - Modular plugin system in lua/plugins/
  - Separated options, keymaps, and plugin configs
  - Lazy loading for better performance

## [0.8.0] - 2024-10-20

### Added
- Zsh configuration with Powerlevel10k
  - Zinit plugin manager
  - Syntax highlighting and completions
  - Zoxide for smart directory navigation
  - Atuin for searchable history
- Shell utility scripts
  - `go-install` for managing Go versions
  - `pg` for PostgreSQL connections with tab completion
- Age encryption for sensitive files
  - Encrypted .env file
  - Encrypted .pgpass file
  - 1Password integration for key management
- Makefile for setup automation
  - `make install` for complete setup
  - `make install-packages` for package installation
  - `make setup-age` for encryption setup
  - OS detection (macOS/Linux)

### Changed
- Migrated from traditional dotfiles to chezmoi management
- Implemented Go templates for cross-platform configuration
- Added PATH management helper function to prevent duplicates

## [0.7.0] - 2024-10-17

### Added
- Initial chezmoi repository setup
- Basic cross-platform support (macOS and Arch Linux)
- Git configuration
- Package lists
  - Brewfile for macOS
  - pkglist.txt for Arch Linux
- System configuration files
  - Logind configuration for suspend/hibernate
  - Systemd journald configuration
  - keyd keyboard remapping

### Changed
- Standardized file naming with chezmoi conventions
  - `dot_` prefix for dotfiles
  - `executable_` prefix for scripts
  - `run_once_` prefix for one-time setup scripts
  - `private_` prefix for encrypted files

## [0.6.0] - 2024-10-15

### Added
- Tmux configuration with TPM
  - vim-tmux-navigator for seamless navigation
  - Mouse support
  - Vi-mode copy keybindings
  - Window/pane management shortcuts
- Alacritty terminal configuration
  - Catppuccin Mocha colorscheme
  - Nerd Font configuration
  - macOS/Linux-specific settings

### Changed
- Improved terminal emulator setup
- Unified color scheme across tools (Catppuccin)

## Earlier Versions

Earlier development history included various configurations and experiments that were consolidated into the current chezmoi-managed structure.

---

## Version Guidelines

This project uses semantic versioning for configuration changes:

- **Major version (X.0.0)**: Breaking changes requiring manual intervention (e.g., restructuring, incompatible updates)
- **Minor version (0.X.0)**: New features, new tools, significant configuration additions
- **Patch version (0.0.X)**: Bug fixes, minor tweaks, documentation updates

## How to Interpret Changes

### Added
New features, scripts, configurations, or tools added to the dotfiles.

### Changed
Modifications to existing configuration, refactoring, or improvements that change behavior.

### Deprecated
Features or configurations that are still present but will be removed in future versions.

### Removed
Features, scripts, or configurations that have been deleted.

### Fixed
Bug fixes, corrections to broken functionality, or improvements to stability.

### Security
Changes related to security, encryption, or sensitive data handling.

## Contributing Changes

When making changes to this configuration:

1. Update this CHANGELOG.md with your changes under `[Unreleased]`
2. Categorize changes appropriately (Added/Changed/Fixed/etc.)
3. Be specific about what changed and why
4. Include file paths when relevant
5. Note any breaking changes or migration steps needed

## Migration Notes

### Upgrading to 1.0.0

No breaking changes. This release adds documentation and polishes existing features.

### Upgrading to 0.9.0

- Run `chezmoi apply` to update tmux configuration and scripts
- Install tmux plugins: `Ctrl-Space + Shift-I` inside tmux
- Ensure Nerd Fonts are installed for proper icon display

### Upgrading to 0.8.0

- Age encryption key required: Get from 1Password or generate new one
- Run `make setup-age` to configure encryption
- Re-apply dotfiles: `chezmoi apply`

### Upgrading to 0.7.0

- First chezmoi version - migration from traditional dotfiles required
- Follow README.md Quick Start section for setup
- Backup existing dotfiles before applying

---

For detailed information about the current configuration, see:
- **README.md** - User documentation and setup guide
- **CLAUDE.md** - AI agent documentation and architecture
- **bin/CLAUDE.md** - Utility script documentation
- **dot_config/tmux/CLAUDE.md** - Tmux configuration details
- **dot_config/nvim/README.md** - Neovim setup guide
