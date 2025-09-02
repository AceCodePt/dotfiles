require('Comment').setup({
  -- ignore new line
  ignore = '^$'
})

local miniAi = require("mini.ai")
miniAi.setup({
  -- Table with textobject id as fields, textobject specification as values.
  -- Also use this to disable builtin textobjects. See |MiniAi.config|.
  custom_textobjects = {
    F = miniAi.gen_spec.treesitter({ i = "@function.inner", a = "@function.outer" }),
    -- s = ai.gen_spec.treesitter({ i = "@function.signature.inner", a = "function.signature.outer" }),
    c = miniAi.gen_spec.treesitter({ i = "@class.inner", a = "@class.outer" }),
  },

  -- Number of lines within which textobject is searched
  n_lines = 50,

  -- How to search for object (first inside current line, then inside
  -- neighborhood). One of 'cover', 'cover_or_next', 'cover_or_prev',
  -- 'cover_or_nearest', 'next', 'previous', 'nearest'.
  search_method = "cover_or_nearest",

  -- Whether to disable showing non-error feedback
  -- This also affects (purely informational) helper messages shown after
  -- idle time if user input is required.
  silent = false,
})

local supported_languages = require("config.supported-languages")
local formatters_by_ft = supported_languages.get_formatters_by_ft()

require("conform").setup({
  formatters_by_ft = formatters_by_ft,
  default_format_opts = {
    stop_after_first = true,
    lsp_format = "fallback",
  },
})
