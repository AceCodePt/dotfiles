return {
  fts = { "javascript", "javascriptreact" },
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
    "tsx"
  },
  formatters = { "prettierd", "prettier" }
}
