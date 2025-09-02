local supported_languages = require("config.supported-languages")
local ensure_installed_languages = supported_languages.get_treesitters()


require('nvim-treesitter.configs').setup({
  -- A list of parser names, or "all" (the listed parsers MUST always be installed)
  ensure_installed = ensure_installed_languages,
  sync_install = false,
  auto_install = false,
  ignore_install = {},
  modules = {},
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true
  }
})
