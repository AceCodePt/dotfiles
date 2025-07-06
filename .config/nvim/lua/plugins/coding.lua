return {
  {
    "echasnovski/mini.comment",
    version = "*",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      options = {
        -- Whether to ignore blank lines when commenting
        ignore_blank_line = true,
      },
    },
  },
  {
    "folke/snacks.nvim",
    opts = {
      input = {
      }
    }
  },
  {
    "stevearc/conform.nvim",
    keys = {
      {
        "<leader>f",
        function()
          local conform = require("conform")
          conform.format({ async = true, lsp_format = "first" })
        end,
        { description = "Format the code" }
      }
    },
    opts = {
      formatters_by_ft = {
        python = { "isort", "black" },
        rust = { "rustfmt", lsp_format = "fallback" },
      },
      -- Set this to change the default values when calling conform.format()
      -- This will also affect the default values for format_on_save/format_after_save
      default_format_opts = {
        lsp_format = "fallback",
      },
      formatters = {
        black = {
          command = "black",
          args = { "--fast", "-" }, -- Common arguments for Black
          stdin = true,
        },
      },
    },
  },
  {
    "norcalli/nvim-colorizer.lua",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("colorizer").setup()
    end,
  },
  {
    "danymat/neogen",
    keys = {
      { "<leader>ng",
        function()
          require("neogen").generate()
        end,
        { noremap = true, silent = true, description = "generate" }
      }
    },
    opts = {
      snippet_engine = "luasnip",
      languages = {
        typescript = {
          template = {
            annotation_convention = "jsdoc",
          },
        },
      },
    },
  },
  {
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    opts = {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "luvit-meta/library", words = { "vim%.uv" } },
      },
    },
  },
  { "Bilal2453/luvit-meta", lazy = true }, -- optional `vim.uv` typings
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      { "tpope/vim-dadbod",                     lazy = true },
      { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql", "mssql" }, lazy = true }, -- Optional
    },
    cmd = {
      "DBUI",
      "DBUIAddConnection",
    },
    init = function()
      vim.g.db_ui_use_nerd_fonts = 1
    end,
  },
}
