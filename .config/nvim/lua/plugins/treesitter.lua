vim.pack.add({
  { src = "https://github.com/nvim-treesitter/nvim-treesitter.git", branch = "master" }
})

local supported_languages = require("config.supported-languages")


-- Extract the 'ts' values and flatten the list in a single line
local ensure_installed_languages = vim.iter(supported_languages)
  :map(function(lang)
    return lang.treesitter
  end)
  :flatten()
  :totable()


require('nvim-treesitter.configs').setup({
  -- A list of parser names, or "all" (the listed parsers MUST always be installed)
  ensure_installed = ensure_installed_languages,
  sync_install = true,
  auto_install = false,
  ignore_install = {},
  modules = {},
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
})
