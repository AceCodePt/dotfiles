-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.

local servers_config = {
  pyright = {
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
  },
  tflint = {},
  terraformls = {},
  lua_ls = {},
  html = {},
  tailwindcss = {},
  cssls = {},
  ts_ls = {},
  eslint = {},
  htmx = {},
  astro = {
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
  },
  sqls = {
    on_attach = function(client, bufnr)
      require("sqls").on_attach(client, bufnr)
    end,
  },
  jsonls = {
    filetypes = { "json", "jsonc" },
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
  },
}

return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "hrsh7th/cmp-nvim-lsp", "nanotee/sqls.nvim" },
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      lspconfig.lua_ls.setup({
        on_init = function(client)
          local path = client.workspace_folders[1].name
          if
              not vim.loop.fs_stat(path .. "/.luarc.json") and not vim.loop.fs_stat(path .. "/.luarc.jsonc")
          then
            client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
              runtime = {
                -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                version = "LuaJIT",
              },
              workspace = {
                library = { vim.env.VIMRUNTIME },
              },
            })

            client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
          end
          return true
        end,
      })

      for server_name, config in pairs(servers_config) do
        lspconfig[server_name].setup(vim.tbl_deep_extend("force", {
          capabilities = capabilities,
          on_attach = function(client, bufnr)
            if config.on_attach ~= nil then
              config.on_attach(client, bufnr)
            end
            local ok, mod = pcall(require, "config.custom-keymaps." .. server_name)
            if ok then
              mod.init(client, bufnr)
            end
          end,
        }, config))
      end

      return {}
    end,
  },
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {},
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      "neovim/nvim-lspconfig",
    },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {},
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      "neovim/nvim-lspconfig",
    },
  },
}
