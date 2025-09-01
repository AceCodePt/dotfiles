return {
  fts = "lua",
  lsp = {
    name = "lua_ls",
    config = {
      settings = {
        Lua = {
          completion = {
            callSnippet = "Disable",    -- Fallback, just in case
            keywordSnippet = "Disable", -- Also disable keyword snippets
          },
          diagnostics = {
            -- Get the language server to recognize the `vim` global
            globals = { 'vim' },
          },
          workspace = {
            -- Make the server aware of Neovim runtime files
            library = vim.api.nvim_get_runtime_file('', true),
          },
        },
      },
    }
  },
  treesitter = "lua",
  formatters = {}
}
