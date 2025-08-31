return {
  fts = { "typescript", "typescriptreact" },
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
    "typescript",
    "tsx"
  },
  formatters = { "prettierd", "prettier" }
}
