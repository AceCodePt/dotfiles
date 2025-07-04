return {
  "mistricky/codesnap.nvim",
  build = "make",
  keys = {
    {
      "<leader>cs",
      ":CodeSnap<cr>",
      { mode = { "x" }, desc = "Code snap to clipboard" }
    },
    {
      "<leader>ca",
      ":CodeSnapSave<cr>",
      { mode = { "x" }, desc = "Save code snap" }
    }
  },
  opts = {
    mac_window_bar = true,
    title = "@sagicarmel",
    code_font_family = "CaskaydiaCove Nerd Font",
    watermark_font_family = "Pacifico",
    watermark = "@sagicarmel",
    bg_theme = "sea",
    breadcrumbs_separator = "/",
    has_breadcrumbs = false,
  }
}
