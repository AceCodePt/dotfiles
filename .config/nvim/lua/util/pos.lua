local M = {}

function M.client_positional_params(client, params)
  local win = vim.api.nvim_get_current_win()
  local ret = vim.util.make_position_params(win, client.offset_encoding)
  if params then
    ret = vim.tbl_extend('force', ret, params)
  end
  return ret
end

return M
