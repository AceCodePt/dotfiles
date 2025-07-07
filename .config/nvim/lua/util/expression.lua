local M = {}

function M.expression(expr)
  local expr_result = vim.fn.expand(expr)
  if not expr_result or expr_result == '' then
    vim.notify("The expression: " .. expr .. ", didn't yield any results", vim.log.levels.ERROR)
    return nil
  end
  return expr_result
end

---@param fn fun(str: string): nil
---@param expr string
function M.create_nvim_keybind_callback(fn, expr)
  return function()
    local result = M.expression(expr)
    if not result then
      return
    end
    fn(result)
  end
end

return M
