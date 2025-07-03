local M = {}
function M.format()
  local conform = require("conform")
  conform.format({ async = true, lsp_format = "fallback" })
end

return M
