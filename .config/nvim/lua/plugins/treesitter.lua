local config = function()
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
         "html",
         "css",
         "sql",
         "comment",
         "vimdoc",
         "tsx",
      },
      highlight = { enable = true },
      indent = { enable = true },
      autotag = { enable = true },
      textobjects = {
         select = {
            enable = true,
            lookahead = true,
            keymaps = {
               ["af"] = "@function.outer",
               ["if"] = "@function.inner",
               ["ac"] = "@class.outer",
               ["ic"] = "@class.inner",
            },
         },
      },
   })
end
return {
   {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      config = config,
   },
}
