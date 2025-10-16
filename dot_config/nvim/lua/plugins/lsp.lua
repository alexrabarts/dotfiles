-- LSP Configuration
return {
  'neovim/nvim-lspconfig',
  dependencies = {
    -- Mason for easy LSP server installation
    { 'williamboman/mason.nvim', config = true },
    'williamboman/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
  },
  config = function()
    -- Get blink.cmp capabilities
    local capabilities = require('blink.cmp').get_lsp_capabilities()

    -- Setup Mason first
    require('mason').setup()

    -- Setup mason-lspconfig with handlers (v2.0+ syntax)
    require('mason-lspconfig').setup {
      ensure_installed = {
        'lua_ls',
        'gopls',
        'ts_ls',
        'rust_analyzer',
        'pyright',
        'bashls',
      },
      handlers = {
        -- Default handler for all servers
        function(server_name)
          require('lspconfig')[server_name].setup {
            capabilities = capabilities,
          }
        end,
        -- Custom handler for lua_ls
        ['lua_ls'] = function()
          require('lspconfig').lua_ls.setup {
            capabilities = capabilities,
            settings = {
              Lua = {
                runtime = { version = 'LuaJIT' },
                workspace = {
                  checkThirdParty = false,
                  library = {
                    '${3rd}/luv/library',
                    unpack(vim.api.nvim_get_runtime_file('', true)),
                  },
                },
                completion = {
                  callSnippet = 'Replace',
                },
                diagnostics = { disable = { 'missing-fields' } },
              },
            },
          }
        end,
      },
    }

    -- LSP keymaps (set when LSP attaches)
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
      callback = function(event)
        local map = function(keys, func, desc)
          vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        -- Jump to definition/references
        map('gd', function() Snacks.picker.lsp_definitions() end, '[G]oto [D]efinition')
        map('gr', function() Snacks.picker.lsp_references() end, '[G]oto [R]eferences')
        map('gI', function() Snacks.picker.lsp_implementations() end, '[G]oto [I]mplementation')
        map('<leader>D', function() Snacks.picker.lsp_type_definitions() end, 'Type [D]efinition')
        map('<leader>ds', function() Snacks.picker.lsp_symbols() end, '[D]ocument [S]ymbols')
        map('<leader>ws', function() Snacks.picker.lsp_workspace_symbols() end, '[W]orkspace [S]ymbols')

        -- Code actions
        map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
        map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

        -- Documentation
        map('K', vim.lsp.buf.hover, 'Hover Documentation')
        map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

        -- Highlight references under cursor
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client.server_capabilities.documentHighlightProvider then
          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            callback = vim.lsp.buf.document_highlight,
          })

          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = event.buf,
            callback = vim.lsp.buf.clear_references,
          })
        end
      end,
    })
  end,
}
