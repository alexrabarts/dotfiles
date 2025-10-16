-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Hyper+hjkl for window navigation (works from any mode)
vim.keymap.set({ 'n', 'i', 't' }, '<M-C-S-h>', '<C-\\><C-n><C-w>h', { desc = 'Move focus to the left window' })
vim.keymap.set({ 'n', 'i', 't' }, '<M-C-S-j>', '<C-\\><C-n><C-w>j', { desc = 'Move focus to the lower window' })
vim.keymap.set({ 'n', 'i', 't' }, '<M-C-S-k>', '<C-\\><C-n><C-w>k', { desc = 'Move focus to the upper window' })
vim.keymap.set({ 'n', 'i', 't' }, '<M-C-S-l>', '<C-\\><C-n><C-w>l', { desc = 'Move focus to the right window' })

-- Buffer navigation
vim.keymap.set('n', '<leader>bn', '<cmd>bnext<CR>', { desc = '[B]uffer [N]ext' })
vim.keymap.set('n', '<leader>bp', '<cmd>bprevious<CR>', { desc = '[B]uffer [P]revious' })
vim.keymap.set('n', '<leader>bd', '<cmd>bdelete<CR>', { desc = '[B]uffer [D]elete' })

-- Quick save
vim.keymap.set('n', '<leader>w', '<cmd>w<CR>', { desc = '[W]rite (save) file' })

-- Quit everything (including terminals)
vim.keymap.set('n', '<leader>Q', '<cmd>qa!<CR>', { desc = '[Q]uit all (force)' })

-- Better indenting in visual mode
vim.keymap.set('v', '<', '<gv', { desc = 'Indent left and reselect' })
vim.keymap.set('v', '>', '>gv', { desc = 'Indent right and reselect' })

-- Move lines up/down in visual mode
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Move line down' })
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Move line up' })

-- Fast access with layer keys (Alt+Ctrl+Shift+key)
-- Works from any mode for quick access
vim.keymap.set({ 'n', 'i', 't' }, '<M-C-S-g>', function()
  -- Get or create the terminal window
  local terminal = require('terminal')
  local win = terminal.ensure_terminal_window()

  -- Switch to the terminal window and open neogit there
  vim.api.nvim_set_current_win(win)
  require('neogit').open({ kind = 'replace' })
end, { desc = 'Open Neogit' })

vim.keymap.set({ 'n', 'i', 't' }, '<M-C-S-c>', function()
  require('terminal').open_terminal('claude', 'claude')
end, { desc = 'Switch to Claude' })

vim.keymap.set({ 'n', 'i', 't' }, '<M-C-S-t>', function()
  require('terminal').open_terminal('general')
end, { desc = 'Switch to Terminal' })
