local M = {
  { language = "lua",    lsp = { name = "lua_ls" },        ts = "lua",    fts = "lua" },
  { language = "python", lsp = { name = "pyright" },       ts = "python", fts = "py" },
  { language = "astro",  lsp = { name = "astro" },         ts = "astro",  fts = "astro" },
  { language = "css",    lsp = { name = "cssls" },         ts = "css",    fts = { "css", "scss", "less" } },
  { language = "html",   lsp = { name = "html" },          ts = "html",   fts = "html" },
  { language = "go",     lsp = { name = "gopls" },         ts = "go",     fts = "go" },
  { language = "rust",   lsp = { name = "rust_analyzer" }, ts = "rust",   fts = "rs" },
  {
    language = "javascript",
    lsp = { name = "ts_ls" },
    ts = "javascript",
    fts = { "js", "jsx" }
  },
  {
    language = "typescript",
    lsp = { name = "ts_ls" },
    ts = {
      "typescript",
      "tsx"
    },
    fts = { "ts", "tsx" }
  },
  { language = "json",     lsp = { name = "jsonls" }, ts = "json",     fts = "json" },
  { language = "yaml",     lsp = { name = "yamlls" }, ts = "yaml",     fts = { "yaml", "yml" } },
  { language = "markdown", lsp = {},                  ts = "markdown", fts = "md" },
  {
    language = "docker",
    lsp = { name = "docker_language_server" },
    ts = "dockerfile",
    fts = { "Dockerfile" },
  },
}

return M
