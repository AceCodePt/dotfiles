vim.pack.add({
  { src = "https://github.com/nvim-treesitter/nvim-treesitter.git", branch = "master" }
})

local supported_languages = require("config.supported-languages")
local ensure_installed_languages = supported_languages.get_treesitters()


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
