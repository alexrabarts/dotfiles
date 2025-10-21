# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a **chezmoi** dotfiles repository that manages shell configuration and system settings across machines. Chezmoi is a dotfile manager that uses templates and supports cross-platform configurations.

### Key Concepts

- **Source directory**: `~/.local/share/chezmoi` (this repository)
- **Target directory**: `~` (home directory where dotfiles are applied)
- Files prefixed with `dot_` become `.` files (e.g., `dot_zshrc` → `~/.zshrc`)
- Files with `.tmpl` extension are Go templates processed by chezmoi with conditional logic
- Files prefixed with `encrypted_` or matching `private_*` are encrypted with age encryption

## Common Development Commands

### Setup (New Machine)
```bash
make install              # Full setup: checks prerequisites, sets up age key, applies dotfiles
make setup-age            # Setup age encryption only
make check-prerequisites  # Verify chezmoi and age are installed
```

### Making Changes
```bash
chezmoi diff              # Preview what would change (ALWAYS run before apply)
chezmoi apply             # Apply changes to home directory
chezmoi apply -v          # Apply with verbose output
chezmoi edit ~/.zshrc     # Edit a managed file (opens editor, prompts to apply)
chezmoi add ~/.newfile    # Add new file to chezmoi management
chezmoi add --encrypt ~/.env  # Add encrypted file
```

### Testing & Validation
```bash
chezmoi doctor            # Check repository and system status
chezmoi execute-template < dot_zshrc.tmpl  # Test template rendering
chezmoi cat ~/.zshrc      # Preview rendered output for a file
```

### Neovim Plugin Management
```bash
# Inside nvim
:Lazy                     # Check plugin status
:Lazy update              # Update all plugins
:Lazy sync                # Install/update/clean plugins
```

## Architecture

### Shell Configuration Flow
1. **Login shells**: `dot_zprofile` → sets up Homebrew environment
2. **Interactive shells**: `dot_zshrc.tmpl` → main configuration with:
   - PATH management via `__path_prepend()` helper (prevents duplicates)
   - Tool integrations: starship, atuin, Google Cloud SDK, bun
   - Chezmoi aliases (cz, czap, cze, czd)
   - Editor setup (prefers nvim → vim → vi)
   - PostgreSQL completion for `pg` command
   - Environment variable loading from encrypted `~/.env`

### Utility Scripts (bin/)
- **go-install**: Installs specific Go versions from official releases to `~/local/go`
  - Auto-detects OS (Linux/Darwin) and architecture (amd64/arm64)
  - Usage: `go-install 1.21.5`
- **pg**: Smart PostgreSQL connection tool using `~/.pgpass`
  - Lists available databases from `~/.pgpass`
  - Connects with: `pg <database-name>`
  - Includes zsh tab completion

### Neovim Configuration Structure
- **init.lua**: Entry point, sets leader key (space), loads modules
- **lua/options.lua**: Editor options
- **lua/keymaps.lua**: Key mappings
- **lua/lazy-bootstrap.lua**: Lazy.nvim plugin manager setup
- **lua/lazy-plugins.lua**: Plugin loading orchestration
- **lua/plugins/**: Modular plugin configs (colorscheme, snacks, todo-comments, mini, telescope, treesitter)

### Encryption with Age
- Age private key stored at `~/.config/age/key.txt` (not in repo)
- Backup location: 1Password document "age-chezmoi-key"
- Encrypted files: `~/.env`, `~/.pgpass`
- Decrypt happens automatically on `chezmoi apply` if key is present

### Template System
Go templates in `.tmpl` files use chezmoi data:
- `.chezmoi.os` - Operating system (e.g., "darwin")
- `.chezmoi.arch` - Architecture (e.g., "arm64")

Template syntax uses `{{- ` and ` -}}` to trim whitespace.

## Important Workflow Notes

- **Always run `chezmoi diff` before `chezmoi apply`** to preview changes
- **Edit source files in this repo**, never edit target files in `~` directly
- Changes to utility scripts in `bin/` require `chezmoi apply` and shell restart
- Neovim config changes take effect on next nvim launch (or `:source $MYVIMRC`)
- The `czap` alias combines `chezmoi apply && exec zsh` for quick iteration
