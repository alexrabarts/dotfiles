-- Neogit - Magit clone for neovim
return {
  'NeogitOrg/neogit',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'folke/snacks.nvim', -- optional - picker integration
  },
  cmd = 'Neogit',
  keys = {
    {
      '<leader>gg',
      '<cmd>Neogit<cr>',
      desc = 'Neogit',
    },
  },
  opts = {
    -- Open neogit in a vsplit on the right (like your terminal)
    kind = 'vsplit',
  },
}
