-- Compatibility shim for nvim-treesitter main branch migration
package.loaded['nvim-treesitter.configs'] = {
  setup = function() end,
  define_modules = function() end,
}
package.loaded['nvim-treesitter.parsers'] = {
  get_parser_configs = function() return {} end,
}

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.session")
require("config.tabs")
require("config.lazy")
