local M = {}

function M.yank(str)
  vim.fn.setreg('+', str)
  vim.notify('Yanked: ' .. str)
end

function M.paste(str)
  vim.api.nvim_put({ str }, 'c', true, true)
end

return M
