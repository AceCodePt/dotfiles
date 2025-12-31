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
  formatters = { "biome", "biome-organize-imports", stop_after_first = false, lsp_format = "never" },
}
