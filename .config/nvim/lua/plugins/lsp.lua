-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.

local languages = {
   "clangd",
   "astro",
   "html",
   "cssls",
   "tsserver",
   "tailwindcss",
   "emmet_ls",
   "pyright",
   "html"
}

return {
   {
      "neovim/nvim-lspconfig",
      dependencies = { "hrsh7th/cmp-nvim-lsp" },
      config = function()
         local capabilities = require("cmp_nvim_lsp").default_capabilities()
         require("lspconfig").lua_ls.setup({
            capabilities = capabilities,
            settings = {
               Lua = {
                  diagnostics = {
                     globals = { "vim", "describe", "it" },
                  },
               },
            },
         })

         local on_attach = function(_, bufnr)
           -- In this case, we create a function that lets us more easily define mappings specific
           -- for LSP related items. It sets the mode, buffer and description for us each time.
           local nmap = function(keys, func, desc)
             if desc then
               desc = 'LSP: ' .. desc
             end

             vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
           end

           nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
           nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
         end

         require("lspconfig").tailwindcss.setup({
            on_attach = function()
               require("tailwindcss-colors").buf_attach(0)
            end,
         })

         for _, language in pairs(languages) do
            require("lspconfig")[language].setup({
               capabilities = capabilities,
               on_attach = on_attach
            })
         end

         vim.keymap.set(
            "n",
            "<Leader>fa",
            ":EslintFixAll<CR>",
            { noremap = true, silent = true }
         )

         vim.lsp.handlers["textDocument/publishDiagnostics"] =
             vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
                virtual_text = false,
             })
      end,
   },
   {
      "williamboman/mason.nvim",
      opts = {},
   },
   {
      "williamboman/mason-lspconfig.nvim",
      opts = {
         ensure_installed = {
            "lua_ls",
            "clangd",
            "html",
            "cssls",
            "tsserver",
            "eslint",
            "tailwindcss",
            "pyright",
            "gopls",
         },
      },
   },
}
