-- Terminal buffer management
-- Provides consistent terminal window on the right with buffer switching

local M = {}

-- Global layout setting (vsplit or fullscreen)
vim.g.terminal_layout = vim.g.terminal_layout or 'vsplit'

-- Store terminal window ID
local terminal_win = nil
local terminal_buffers = {}

-- Find or create the terminal window
local function ensure_terminal_window()
  -- Check if terminal window still exists and is valid
  if terminal_win and vim.api.nvim_win_is_valid(terminal_win) then
    return terminal_win
  end

  local layout = vim.g.terminal_layout

  if layout == 'vsplit' then
    -- Create right-side vertical split (50%)
    vim.cmd('vsplit')
    terminal_win = vim.api.nvim_get_current_win()
    -- Set width to 50%
    local total_width = vim.o.columns
    vim.api.nvim_win_set_width(terminal_win, math.floor(total_width * 0.5))
  else
    -- Fullscreen mode - create floating window
    local width = math.floor(vim.o.columns * 0.9)
    local height = math.floor(vim.o.lines * 0.9)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    local buf = vim.api.nvim_create_buf(false, true)
    terminal_win = vim.api.nvim_open_win(buf, true, {
      relative = 'editor',
      width = width,
      height = height,
      row = row,
      col = col,
      style = 'minimal',
      border = 'rounded',
    })
  end

  return terminal_win
end

-- Switch to a terminal buffer by name, or create it
function M.open_terminal(name, cmd)
  -- Check if we already have this terminal buffer
  if terminal_buffers[name] and vim.api.nvim_buf_is_valid(terminal_buffers[name]) then
    -- Ensure we have a terminal window
    local win = ensure_terminal_window()
    -- Switch to existing buffer
    vim.api.nvim_win_set_buf(win, terminal_buffers[name])
    vim.api.nvim_set_current_win(win)
  else
    -- Create new terminal buffer first
    local buf = vim.api.nvim_create_buf(false, true)

    -- Open terminal in the buffer
    vim.api.nvim_buf_call(buf, function()
      if cmd then
        vim.fn.termopen(cmd)
      else
        vim.fn.termopen(vim.o.shell)
      end
    end)

    terminal_buffers[name] = buf

    -- Now ensure window exists and set the buffer
    local win = ensure_terminal_window()
    vim.api.nvim_win_set_buf(win, buf)
    vim.api.nvim_set_current_win(win)
  end

  -- Enter terminal mode
  vim.cmd('startinsert')
end

-- Create a new unnamed terminal
function M.new_terminal()
  local win = ensure_terminal_window()
  vim.api.nvim_set_current_win(win)
  vim.cmd('terminal')
  vim.cmd('startinsert')
end

-- Toggle layout between vsplit and fullscreen
function M.toggle_layout()
  if vim.g.terminal_layout == 'vsplit' then
    vim.g.terminal_layout = 'fullscreen'
    print('Terminal layout: fullscreen')
  else
    vim.g.terminal_layout = 'vsplit'
    print('Terminal layout: vsplit')
  end

  -- Close current terminal window to force recreation with new layout
  if terminal_win and vim.api.nvim_win_is_valid(terminal_win) then
    vim.api.nvim_win_close(terminal_win, false)
    terminal_win = nil
  end
end

-- Export ensure_terminal_window for use by other plugins
M.ensure_terminal_window = ensure_terminal_window

-- Auto-enter insert mode when entering a terminal buffer
vim.api.nvim_create_autocmd({ 'BufEnter', 'WinEnter' }, {
  pattern = 'term://*',
  callback = function()
    -- Disable line numbers in terminal
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    -- Hide whitespace indicators in terminal
    vim.opt_local.list = false
    -- Enter insert mode
    vim.cmd('startinsert')
  end,
  desc = 'Auto-enter insert mode in terminal buffers',
})

return M
