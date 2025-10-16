-- TokyoNight colorscheme
return {
  'folke/tokyonight.nvim',
  priority = 1000, -- Load before other plugins
  config = function()
    require('tokyonight').setup {
      style = 'night', -- storm, moon, night, or day
      transparent = false,
      terminal_colors = true,
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
        functions = {},
        variables = {},
      },
    }
    -- Load the colorscheme
    vim.cmd.colorscheme 'tokyonight'
  end,
}
