return {
  fts = "json",
  lsp = { name = "jsonls" ,
  config = {
    settings = {
      json = {
        -- Schemas https://www.schemastore.org
        schemas = {
            {
            fileMatch = { "opencode.json*" },
              url = "https://opencodsoe.ai/config.json",
            },
          {
            fileMatch = { "package.json" },
            url = "https://json.schemastore.org/package.json",
          },
          {
            fileMatch = { "tsconfig*.json" },
            url = "https://json.schemastore.org/tsconfig.json",
          },
          {
            fileMatch = {
              ".prettierrc",
              ".prettierrc.json",
              "prettier.config.json",
            },
            url = "https://json.schemastore.org/prettierrc.json",
          },
          {
            fileMatch = { ".eslintrc", ".eslintrc.json" },
            url = "https://json.schemastore.org/eslintrc.json",
          },
          {
            fileMatch = { ".babelrc", ".babelrc.json", "babel.config.json" },
            url = "https://json.schemastore.org/babelrc.json",
          },
          {
            fileMatch = { "now.json", "vercel.json" },
            url = "https://json.schemastore.org/now.json",
          },
        },
      },
    },
  }
},
  treesitter = "json",
  formatters = {},
}
