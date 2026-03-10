return {
  fts = { "javascript", "javascriptreact" },
  lsp = {
    name = "vtsls",
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
  formatters = { "prettier", stop_after_first = false, lsp_format = "never" },
}
