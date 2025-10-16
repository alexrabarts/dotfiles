-- blink.cmp - Fast completion engine
return {
  'saghen/blink.cmp',
  dependencies = { 'rafamadriz/friendly-snippets' },

  -- Use a release tag to download pre-built binaries
  version = '*',

  ---@type blink.cmp.Config
  opts = {
    keymap = { preset = 'default' },

    appearance = {
      use_nvim_cmp_as_default = true,
      nerd_font_variant = 'mono',
    },

    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
    },
  },
}
