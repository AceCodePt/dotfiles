local M = {
  { ts = "lua",    fts = "lua", lsp = "lua_ls" },
  { ts = "python", fts = "py",  lsp = "pyright" },
  {
    ts = {
      "javascript",
      "typescript",
      "tsx"
    },
    fts = { "ts", "js", "tsx", "jsx" },
    lsp = "ts_ls"
  },
  { ts = "astro", fts = "astro",                   lsp = "astro" },
  { ts = "css",   fts = { "css", "scss", "less" }, lsp = "cssls" },
  { ts = "go",    fts = "go",                      lsp = "gopls" },
  { ts = "rust",  fts = "rs",                      lsp = "rust_analyzer" },
}

return M
