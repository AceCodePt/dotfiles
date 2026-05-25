local supported_languages = require("config.supported-languages")
local ensure_installed_languages = supported_languages.get_treesitters()

local ts = require('nvim-treesitter')

ts.install(ensure_installed_languages)

-- Enable highlighting
vim.api.nvim_create_autocmd('FileType', {
  callback = function(args)
    local bufnr = args.buf
    local ft = vim.bo[bufnr].filetype
    local lang = vim.treesitter.language.get_lang(ft)
    if lang then
      pcall(vim.treesitter.start, bufnr, lang)
    end
  end,
})
