return {
  fts = "python",
  treesitter = "python",
  formatters = { "ruff" },
  lsp = {
    name = "pyright",
    config = {
      filetypes = { "python" },
      settings = {
        python = {
          pythonPath = (function()
            local venv = vim.fn.findfile(".venv/bin/python", vim.fn.getcwd() .. ";")
            if venv ~= "" then
              return venv
            end
            return vim.fn.exepath("python3")
          end)(),
        },
      },
    }
  },
}
