local supported_languages = require("config.supported-languages")
local ensure_installed = {}

require("mason").setup({})

for _, lsp in pairs(supported_languages.get_lsp_by_ft()) do
  if lsp.name then
    local opts = {}
    -- Merge custom config if it exists
    if lsp.config then
      opts = vim.tbl_deep_extend("force", opts, lsp.config)
      if lsp.config.on_attach then
        opts.on_attach = function(client, bufnr)
          lsp.config.on_attach(client, bufnr)
        end
      end
    end
    table.insert(ensure_installed, lsp.name)

    -- Set up the LSP server
    vim.lsp.config(lsp.name, opts)
    vim.lsp.enable(lsp.name)
  end
end


require("mason-lspconfig").setup({
  automatic_enable = false,
  ensure_installed = ensure_installed,
})

vim.diagnostic.config({
  virtual_lines = false,
  virtual_text = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})
