local M = {}
function M.format()
  local conform = require("conform")
  conform.format({ async = true, lsp_format = "first" })
end

---@param text string
function M.format_text(text)
  local conform = require("conform")
  local stuff = conform.list_formatters_for_buffer(0)
  local lines_to_format = vim.split(text, "\n")
  local err, new_lines = conform.format_lines(stuff, lines_to_format, { async = false })
  vim.schedule(function()
    vim.notify(vim.inspect(err) .. vim.inspect(new_lines))
  end)
  if err or not new_lines then
    return nil
  end
  return table.concat(new_lines, "\n")
end

return M
