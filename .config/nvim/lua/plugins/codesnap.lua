
local M = require("util.map")
local map = M.map

return {
   "mistricky/codesnap.nvim",
   build = "make",
   config = function()
      require("codesnap").setup({
         mac_window_bar = true,
         title = "@sagicarmel",
         code_font_family = "CaskaydiaCove Nerd Font",
         watermark_font_family = "Pacifico",
         watermark = "@sagicarmel",
         bg_theme = "sea",
         breadcrumbs_separator = "/",
         has_breadcrumbs = false,
      })
      map({"x"}, "<leader>cs", ":CodeSnap<cr>")
   end,
}


