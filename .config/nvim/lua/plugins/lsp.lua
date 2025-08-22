vim.pack.add({
  { src = "https://github.com/mason-org/mason.nvim" },
  { src = 'https://github.com/neovim/nvim-lspconfig' },
  { src = 'https://github.com/mason-org/mason-lspconfig.nvim' }
})

local supported_languages = require("config.supported-languages")
local ensure_installed_languages = vim.iter(supported_languages)
    :map(function(lang)
      return lang.lsp.name
    end)
    :totable()


require("mason-lspconfig").setup({
  ensure_installed = ensure_installed_languages
})
