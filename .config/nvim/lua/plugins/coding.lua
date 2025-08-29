vim.pack.add({
  { src = "https://github.com/stevearc/conform.nvim" },
  { src = "https://github.com/numToStr/Comment.nvim" }
})

require('Comment').setup({
  ignore = '^$'
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
