-- snacks.nvim - Collection of QoL plugins
return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    bigfile = { enabled = true },
    notifier = { enabled = true },
    quickfile = { enabled = true },
    statuscolumn = { enabled = false },
    words = { enabled = true },
    lazygit = { enabled = true },
    picker = {
      enabled = true,
      win = {
        input = {
          keys = {
            -- Toggle hidden files with <M-h>
            ["<M-h>"] = { "toggle_hidden", mode = { "n", "i" } },
            -- Toggle ignored files with <M-i>
            ["<M-i>"] = { "toggle_ignored", mode = { "n", "i" } },
          },
        },
      },
      sources = {
        files = {
          hidden = true,
          ignored = false,
        },
        grep = {
          hidden = true,
          ignored = false,
        },
      },
    },
    explorer = { enabled = true },
  },
  keys = {
    -- Terminal keymaps
    {
      '<leader>tc',
      function()
        require('terminal').open_terminal('claude', 'claude')
      end,
      desc = '[T]erminal [C]laude',
    },
    {
      '<leader>tt',
      function()
        require('terminal').open_terminal('general')
      end,
      desc = '[T]erminal [T]oggle',
    },
    {
      '<leader>tn',
      function()
        require('terminal').new_terminal()
      end,
      desc = '[T]erminal [N]ew',
    },
    {
      '<leader>tl',
      function()
        require('terminal').toggle_layout()
      end,
      desc = '[T]erminal [L]ayout Toggle',
    },
    -- File explorer
    {
      '<leader>e',
      function()
        Snacks.explorer()
      end,
      desc = 'Toggle file explorer',
    },
    -- Picker keymaps (replacing Telescope)
    {
      '<leader>sh',
      function()
        Snacks.picker.help()
      end,
      desc = '[S]earch [H]elp',
    },
    {
      '<leader>sk',
      function()
        Snacks.picker.keymaps()
      end,
      desc = '[S]earch [K]eymaps',
    },
    {
      '<leader>sf',
      function()
        Snacks.picker.files()
      end,
      desc = '[S]earch [F]iles',
    },
    {
      '<leader>ss',
      function()
        Snacks.picker.pickers()
      end,
      desc = '[S]earch [S]elect Picker',
    },
    {
      '<leader>sw',
      function()
        Snacks.picker.grep_word()
      end,
      desc = '[S]earch current [W]ord',
    },
    {
      '<leader>sg',
      function()
        Snacks.picker.grep()
      end,
      desc = '[S]earch by [G]rep',
    },
    {
      '<leader>sd',
      function()
        Snacks.picker.diagnostics()
      end,
      desc = '[S]earch [D]iagnostics',
    },
    {
      '<leader>sr',
      function()
        Snacks.picker.resume()
      end,
      desc = '[S]earch [R]esume',
    },
    {
      '<leader>s.',
      function()
        Snacks.picker.recent()
      end,
      desc = '[S]earch Recent Files ("." for repeat)',
    },
    {
      '<leader><leader>',
      function()
        Snacks.picker.buffers()
      end,
      desc = '[ ] Find existing buffers',
    },
    {
      '<leader>gs',
      function()
        Snacks.picker.git_status()
      end,
      desc = '[G]it [S]tatus',
    },
  },
}
