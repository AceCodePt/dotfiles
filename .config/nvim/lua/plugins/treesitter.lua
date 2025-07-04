return {
  "nvim-treesitter/nvim-treesitter",
  dependencies = {
    "nvim-treesitter/nvim-treesitter-textobjects",
  },
  event = { "BufReadPre", "BufNewFile" },
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      auto_install = false,

      sync_install = true,
      ignore_install = {},
      modules = {},

      ensure_installed = {
        "c",
        "cpp",
        "python",
        "lua",
        "vim",
        "javascript",
        "typescript",
        "astro",
        "json",
        "html",
        "css",
        "sql",
        "comment",
        "vimdoc",
        "tsx",
      },
      highlight = { enable = true },
      indent = { enable = false },
      autotag = { enable = false },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<leader>ti",
          scope_incremental = "<leader>ts",
          node_incremental = "<leader>ti",
          node_decremental = "<leader>td",
        },
      },
      textobjects = {
        select = {
          enable = true,
          -- Automatically jump forward to textobj, similar to targets.vim
          lookahead = true,
        },
        -- You can also enable 'swap' and 'move' textobjects if you want
        -- swap = {
        --   enable = true,
        --   swap_next = { ["<leader>a"] = "@parameter.inner" },
        --   swap_previous = { ["<leader>A"] = "@parameter.inner" },
        -- },
        -- move = {
        --   enable = true,
        --   goto_next_start = { ["]f"] = "@function.outer" },
        --   goto_previous_start = { ["[f"] = "@function.outer" },
        -- },
      },
    })
  end
}
