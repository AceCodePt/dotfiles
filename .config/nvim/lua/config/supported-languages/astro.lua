local typescript_on_attach = require("config.supported-languages.typescript").lsp.config.on_attach

return {
  fts = "astro",
  treesitter = "astro",
  formatters = { "prettierd", "prettier" },
  lsp = {
    name = "astro",
    config = {
      init_options = {
        typescript = {
        }
      },
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
      on_attach = function(client, bufnr)
        typescript_on_attach(client, bufnr)
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
                notify(e.match, 3)
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
}
