# Neovim Configuration

A customized Neovim setup built on top of [LazyVim](https://github.com/LazyVim/LazyVim), optimized for development work with Go, TypeScript, Lua, and other languages.

## Overview

This configuration provides a complete IDE-like experience with:

- **Modern plugin management** with lazy.nvim
- **LSP integration** for intelligent code completion and navigation
- **Treesitter** for advanced syntax highlighting
- **Git integration** with Neogit and Gitsigns
- **Fuzzy finding** with Snacks picker (Telescope alternative)
- **Catppuccin Mocha** colorscheme (currently using TokyoNight)
- **Minimal, fast startup** with lazy loading

## Features

### Language Support

Configured LSP servers (auto-installed via Mason):
- **Lua** (lua_ls) - Neovim configuration, Lua development
- **Go** (gopls) - Go development with full LSP features
- **TypeScript/JavaScript** (ts_ls) - Web development
- **Rust** (rust_analyzer) - Rust development
- **Python** (pyright) - Python development
- **Bash** (bashls) - Shell scripting

### Key Plugins

- **lazy.nvim** - Fast, modern plugin manager
- **mason.nvim** - LSP/DAP/linter/formatter installer
- **nvim-lspconfig** - LSP client configurations
- **blink.cmp** - Fast completion engine
- **nvim-treesitter** - Advanced syntax highlighting and code understanding
- **snacks.nvim** - Collection of utilities (picker, terminal, notifications)
- **neogit** - Magit-style git interface
- **gitsigns.nvim** - Git decorations and blame
- **mini.nvim** - Collection of minimal plugins (surround, pairs, etc.)
- **tokyonight.nvim** - Colorscheme

## Structure

```
dot_config/nvim/
├── init.lua                  # Entry point, loads modules
├── lua/
│   ├── options.lua           # Editor settings (line numbers, tabs, etc.)
│   ├── keymaps.lua           # Custom keybindings (currently minimal)
│   ├── lazy-bootstrap.lua    # Lazy.nvim installation
│   ├── lazy-plugins.lua      # Plugin loading orchestration
│   ├── terminal.lua          # Terminal configuration
│   └── plugins/              # Individual plugin configurations
│       ├── colorscheme.lua   # TokyoNight theme setup
│       ├── lsp.lua           # LSP configuration with Mason
│       ├── blink-cmp.lua     # Completion engine
│       ├── treesitter.lua    # Syntax highlighting
│       ├── gitsigns.lua      # Git decorations
│       ├── neogit.lua        # Git interface
│       ├── snacks.lua        # Snacks utilities
│       ├── mini.lua          # Mini plugins
│       └── ...               # Other plugin configs
└── plugin/                   # Auto-loaded vim scripts
```

## Configuration Files

### init.lua

Main entry point that:
1. Sets leader key to Space
2. Loads options and keymaps
3. Bootstraps lazy.nvim
4. Loads all plugins

### lua/options.lua

Editor settings including:
- Line numbers (absolute, relative disabled in `config/options.lua`)
- Mouse support enabled
- System clipboard integration
- Smart case searching
- Split behavior (right/below)
- Tab width: 2 spaces
- Scrolloff: 10 lines
- Cursorline highlighting
- Persistent undo history

### lua/plugins/lsp.lua

LSP configuration with:
- Mason for automatic LSP installation
- Pre-configured servers for common languages
- Blink.cmp integration for completion
- Custom keymaps that activate on LSP attach
- Document highlight on cursor hold

### lua/plugins/colorscheme.lua

Currently configured with TokyoNight:
- Style: night
- Italic comments and keywords
- Terminal colors enabled

## Key Bindings

### Leader Key

The leader key is **Space**.

### LSP Keybindings

These activate when an LSP server is attached to a buffer:

**Navigation**:
- `gd` - Go to definition (fuzzy)
- `gr` - Go to references (fuzzy)
- `gI` - Go to implementation
- `gD` - Go to declaration
- `K` - Hover documentation

**Code Actions**:
- `<leader>rn` - Rename symbol
- `<leader>ca` - Code action
- `<leader>D` - Type definition
- `<leader>ds` - Document symbols
- `<leader>ws` - Workspace symbols

### Default LazyVim Keybindings

This configuration inherits many keybindings from LazyVim. Key ones include:

**File/Buffer Management**:
- `<leader>ff` - Find files
- `<leader>fg` - Live grep
- `<leader>fb` - Find buffers
- `<leader>fr` - Recent files
- `<leader>bd` - Delete buffer
- `<leader>bD` - Delete other buffers

**Window Management**:
- `<C-h/j/k/l>` - Navigate windows (integrates with tmux via vim-tmux-navigator)
- `<leader>w-` - Split window horizontally
- `<leader>w|` - Split window vertically
- `<leader>wd` - Close window

**Git**:
- `<leader>gg` - Open Neogit
- `<leader>gb` - Git blame line
- `]h` / `[h` - Next/previous git hunk
- `<leader>hs` - Stage hunk
- `<leader>hr` - Reset hunk

**Terminal**:
- `<C-/>` - Toggle terminal
- `<C-_>` - Terminal (alternative binding)

**Other**:
- `<leader>l` - Lazy plugin manager UI
- `<leader>e` - File explorer (if configured)
- `<leader>z` - Toggle zen mode (if configured)
- `<leader>uc` - Toggle colorscheme
- `<leader>ul` - Toggle line numbers
- `<leader>ur` - Toggle relative line numbers

Refer to [LazyVim keymaps documentation](https://www.lazyvim.org/keymaps) for the complete list.

## Usage

### First-Time Setup

After applying dotfiles with chezmoi, open Neovim:

```bash
nvim
```

On first launch:
1. Lazy.nvim will automatically install itself
2. All plugins will be installed
3. Mason will install configured LSP servers
4. Treesitter parsers will be installed

This may take a minute or two on first run.

### Managing Plugins

**Open Lazy UI**:
```vim
:Lazy
```

**Update all plugins**:
```vim
:Lazy update
```

**Sync plugins** (install missing, update, clean removed):
```vim
:Lazy sync
```

**Clean unused plugins**:
```vim
:Lazy clean
```

### Managing LSP Servers

**Open Mason UI**:
```vim
:Mason
```

**Install a server manually**:
```vim
:MasonInstall <server-name>
```

**Update all servers**:
```vim
:MasonUpdate
```

### Checking Health

Neovim provides a health check system:

```vim
:checkhealth
```

This will show:
- Neovim version and build info
- Required tools and their status
- Plugin health
- LSP server status
- Clipboard integration status

### Finding Files and Text

**Find files** (uses Snacks picker):
```vim
:lua Snacks.picker.files()
" Or: <leader>ff (if LazyVim keymap is active)
```

**Live grep** (search in files):
```vim
:lua Snacks.picker.grep()
" Or: <leader>fg
```

**Find in current buffer**:
```vim
:lua Snacks.picker.lines()
```

### Git Operations

**Open Neogit** (Magit-style interface):
```vim
:Neogit
" Or: <leader>gg
```

Inside Neogit:
- `s` - Stage file/hunk
- `u` - Unstage file/hunk
- `c` - Commit menu
- `P` - Push menu
- `F` - Pull menu
- `?` - Show help
- `q` - Quit

**View git blame**:
```vim
:Gitsigns blame_line
" Or: <leader>gb
```

**Stage current hunk**:
```vim
:Gitsigns stage_hunk
" Or: <leader>hs
```

### Terminal

**Toggle floating terminal**:
```vim
<Ctrl-/>
```

**Exit terminal mode**:
```vim
<Ctrl-\><Ctrl-n>
```

Then use normal mode commands to navigate, or close with `:q`.

## Customization

### Adding a New Language

1. Find the LSP server name at [LSP server configurations](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md)

2. Add to `lua/plugins/lsp.lua`:
```lua
ensure_installed = {
  'lua_ls',
  'gopls',
  'your_new_lsp',  -- Add here
},
```

3. Restart Neovim - Mason will install it automatically

4. Add Treesitter parser in `lua/plugins/treesitter.lua` if needed:
```lua
ensure_installed = {
  'lua',
  'go',
  'your_language',  -- Add here
},
```

### Changing Colorscheme

The configuration includes multiple colorscheme plugins. To switch:

1. Edit `lua/plugins/colorscheme.lua`
2. Change the active colorscheme:
```lua
vim.cmd.colorscheme 'catppuccin-mocha'  -- or 'tokyonight', etc.
```

Available themes (if plugins are loaded):
- `tokyonight` (styles: night, storm, moon, day)
- `catppuccin-mocha` (or latte, frappe, macchiato)
- Others as configured in `lua/plugins/all-themes.lua`

### Adding Custom Keymaps

Add to `lua/config/keymaps.lua`:

```lua
-- Example custom keymaps
vim.keymap.set('n', '<leader>w', ':w<CR>', { desc = 'Save file' })
vim.keymap.set('n', '<leader>q', ':q<CR>', { desc = 'Quit' })
vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Scroll down and center' })
```

### Modifying Options

Add to `lua/config/options.lua`:

```lua
vim.opt.relativenumber = true   -- Enable relative line numbers
vim.opt.tabstop = 4             -- 4-space tabs
vim.opt.colorcolumn = '80'      -- Show column at 80 chars
```

### Adding a Plugin

Create a new file in `lua/plugins/`:

```lua
-- lua/plugins/your-plugin.lua
return {
  'username/plugin-name',
  config = function()
    require('plugin-name').setup({
      -- configuration here
    })
  end,
}
```

Lazy.nvim automatically loads all files in `lua/plugins/`.

## Troubleshooting

### LSP Not Working

**Problem**: No code completion or LSP features

**Solution**:
```vim
" Check LSP status
:LspInfo

" Check if server is installed
:Mason

" Restart LSP
:LspRestart

" Check logs
:lua vim.cmd('edit ' .. vim.lsp.get_log_path())
```

### Treesitter Highlighting Issues

**Problem**: Syntax highlighting not working or errors

**Solution**:
```vim
" Update parsers
:TSUpdate

" Check parser status
:TSInstallInfo

" Reinstall specific parser
:TSInstall! <language>
```

### Plugin Not Loading

**Problem**: Plugin doesn't seem to be active

**Solution**:
```vim
" Check Lazy status
:Lazy

" Look for errors or "not loaded" status
" Try syncing
:Lazy sync

" Check startup logs
:messages
```

### Slow Startup

**Problem**: Neovim takes long to start

**Solution**:
```vim
" Profile startup time
:Lazy profile

" Check what's taking time
" Consider lazy-loading more plugins
```

In plugin config, add:
```lua
{
  'plugin-name',
  lazy = true,        -- Don't load at startup
  cmd = 'PluginCmd',  -- Load on command
  ft = 'filetype',    -- Load on filetype
  keys = '<leader>x', -- Load on keymap
}
```

### Clipboard Not Working

**Problem**: Can't copy/paste to system clipboard

**Solution**:

Check clipboard support:
```vim
:checkhealth clipboard
```

**On Linux**: Install xclip or xsel:
```bash
sudo pacman -S xclip
```

**On macOS**: Should work by default

**Via SSH**: Use terminal emulator's clipboard, or:
- Use tmux with `tmux-yank` plugin
- Use OSC 52 sequences (some terminals)

### Keybindings Not Working

**Problem**: Expected keybinding doesn't work

**Solution**:
```vim
" Check what key is mapped to
:map <leader>ff
:nmap <leader>ff

" Check all leader mappings
:map <leader>

" Check for conflicts
:verbose map <leader>ff
```

## Performance Tips

1. **Lazy load plugins**: Most plugins in this config are lazy-loaded based on filetypes, commands, or keymaps

2. **Limit LSP servers**: Only install servers you need

3. **Reduce Treesitter parsers**: Only install for languages you use

4. **Profile startup**: Use `:Lazy profile` to identify slow plugins

5. **Disable unused features**: Comment out plugin configs you don't use

## Related Documentation

- **CLAUDE.md** (root) - Overall repository architecture
- **README.md** (root) - Setup and usage guide
- [LazyVim Documentation](https://www.lazyvim.org/) - Base configuration reference
- [lazy.nvim Documentation](https://github.com/folke/lazy.nvim) - Plugin manager
- [LSP Config Documentation](https://github.com/neovim/nvim-lspconfig) - LSP setup

## Resources

- [LazyVim Official Site](https://www.lazyvim.org/)
- [Neovim Documentation](https://neovim.io/doc/)
- [LSP Server Configurations](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md)
- [Treesitter Supported Languages](https://github.com/nvim-treesitter/nvim-treesitter#supported-languages)
- [Mason Registry](https://mason-registry.dev/registry/list) - Available LSP servers and tools
