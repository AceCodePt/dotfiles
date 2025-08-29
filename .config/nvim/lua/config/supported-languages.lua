local M = {
  {
    fts = "lua",
    lsp = {
      name = "lua_ls",
      config = {
        settings = {
          Lua = {
            diagnostics = {
              -- Get the language server to recognize the `vim` global
              globals = { 'vim' },
            },
            workspace = {
              -- Make the server aware of Neovim runtime files
              library = vim.api.nvim_get_runtime_file('', true),
            },
          },
        },
      }
    },
    treesitter = "lua",
    formatters = {}
  },
  {
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
  },
  {
    fts = "astro",
    treesitter = "astro",
    formatters = { "prettierd", "prettier" },
    lsp = {
      name = "astro",
      config = {
        on_attach = function(client, _)
          vim.api.nvim_create_autocmd("BufWritePost", {
            pattern = { "*.js", "*.ts" },
            group = vim.api.nvim_create_augroup("astro_ondidchangetsorjsfile", { clear = true }),
            callback = function(ctx)
              client.notify("workspace/didChangeWatchedFiles", {
                changes = {
                  {
                    uri = ctx.match,
                    type = 2, -- 1 = Created, 2 = Changed, 3 = Deleted
                  },
                },
              })
            end,
          })
        end,
      }
    },
  },
  {
    fts = "css",
    lsp = { name = "cssls" },
    treesitter = "css",
    formatters = {}
  },
  {
    fts = "html",
    lsp = { name = "html" },
    treesitter = "html",
    formatters = {}
  },
  {
    fts = "go",
    lsp = { name = "gopls" },
    treesitter = "go",
    formatters = {}
  },
  {
    fts = "rust",
    lsp = { name = "rust_analyzer" },
    treesitter = "rust",
    formatters = { "rustfmt" }
  },
  {
    fts = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
    lsp = { name = "ts_ls" },
    treesitter = {
      "javascript",
      "typescript",
      "tsx"
    },
    formatters = { "prettierd", "prettier" }
  },
  {
    fts = "json",
    lsp = { name = "jsonls" },
    treesitter = "json",
    formatters = {},
    config = {
      settings = {
        json = {
          -- Schemas https://www.schemastore.org
          schemas = {
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
  {
    fts = "yaml",
    lsp = { name = "yamlls" },
    treesitter = "yaml",
    formatters = {}
  },
  {
    fts = "markdown",
    lsp = { name = "markdown_oxide" },
    treesitter = "markdown",
    formatters = {}
  },
  {
    fts = "dockerfile",
    lsp = { name = "docker_language_server" },
    treesitter = "dockerfile",
    formatters = {}
  },
}

return M
