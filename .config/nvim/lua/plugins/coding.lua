vim.pack.add({
  { src = "https://github.com/stevearc/conform.nvim" },
  { src = "https://github.com/numToStr/Comment.nvim" },
  { src = "https://github.com/echasnovski/mini.ai" }
})

require('Comment').setup({
  -- ignore new line
  ignore = '^$'
})

local miniAi = require("mini.ai")
miniAi.setup({
  -- Table with textobject id as fields, textobject specification as values.
  -- Also use this to disable builtin textobjects. See |MiniAi.config|.
  custom_textobjects = {
    f = miniAi.gen_spec.treesitter({ i = "@function.inner", a = "@function.outer" }),
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
local formatters_by_ft = {}

-- Iterate through the supported_languages table
for _, lang in ipairs(supported_languages) do
  -- Ensure that the language has formatters
  if #lang.formatters > 0 then
    -- If the fts is a single string, set the formatter
    if type(lang.fts) == "string" then
      formatters_by_ft[lang.fts] = lang.formatters
      -- If the fts is a table of strings, iterate and set the formatter for each
    elseif type(lang.fts) == "table" then
      for _, ft in ipairs(lang.fts) do
        formatters_by_ft[ft] = lang.formatters
      end
    end
  end
end


require("conform").setup({
  formatters_by_ft = formatters_by_ft,
  default_format_opts = {
    stop_after_first = true,
    lsp_format = "fallback",
  },
})
