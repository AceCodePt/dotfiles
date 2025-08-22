vim.pack.add({
  { src = 'https://github.com/neovim/nvim-lspconfig' },
  { src = "https://github.com/mason-org/mason.nvim" },
})

local supported_languages = require("config.supported-languages")


require("mason").setup({})
for _, lang in pairs(supported_languages) do
  local opts = {}

  -- Merge custom config if it exists
  if lang.lsp.config then
    opts = vim.tbl_deep_extend("force", opts, lang.lsp.config)
    if lang.lsp.config.on_attach then
      opts.on_attach = function(client, bufnr)
        lang.lsp.config.on_attach(client, bufnr)
      end
    end
  end



  -- Set up the LSP server
  vim.lsp.config(lang.lsp.name, opts)
  vim.lsp.enable(lang.lsp.name)
end

vim.diagnostic.config({
  virtual_lines = false,
  virtual_text = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})
