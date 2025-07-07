local M = {}

function M.yank(str)
  vim.fn.setreg('"', str)
end

function M.paste(str)
  local current_mode = vim.fn.mode()
  local prefix = current_mode == "n" and 'i' or 'c'
  vim.api.nvim_feedkeys(prefix .. str, 'n', true)
end

return M
