return {
  fts = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
  lsp = {
    name = "ts_ls",
    config = {
      capabilities = {
        workspace = {
          didChangeWatchedFiles = {
            dynamicRegistration = true,
          },
        },
      },
    }
  },
  treesitter = {
    "javascript",
    "typescript",
    "tsx"
  },
  formatters = { "prettierd", "prettier" }
}
