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
        settings = {
          astro = {
            updateImportsOnFileMove = {
              enabled = 'always'
            }
          }
        },
        capabilities = {
          workspace = {
            didChangeWatchedFiles = {
              dynamicRegistration = true,
            },
          },
        },
        on_attach = function(client, _)
          local group = vim.api.nvim_create_augroup("astro_lsp_patches", { clear = true })
          local notify = function(match, type)
            client:notify("workspace/didChangeWatchedFiles", {
              changes = {
                {
                  uri = match,
                  type = type, -- 1 = Created, 2 = Changed, 3 = Deleted
                },
              },
            })
          end
          vim.api.nvim_create_autocmd("User", {
            pattern = "OilActionsPost",
            group = group,
            callback = function(e)
              if e.data.actions == nil then
                return
              end
              for _, action in ipairs(e.data.actions) do
                if action.entry_type == "file" and action.type == "create" then
                  notify(e.match, 1)
                end
                if action.entry_type == "file" and action.type == "delete" then
                  local file = action.url:sub(7)
                  local bufnr = vim.fn.bufnr(file)

                  if bufnr >= 0 then
                    vim.api.nvim_buf_delete(bufnr, { force = true })
                    notify(e.match, 3)
                  end
                end
              end
            end,
          })
          vim.api.nvim_create_autocmd("BufWritePost", {
            pattern = { "*.js", "*.ts" },
            group = group,
            callback = function(e)
              notify(e.match, 2)
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
