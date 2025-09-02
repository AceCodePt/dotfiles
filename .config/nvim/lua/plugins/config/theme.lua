vim.cmd.colorscheme [[tokyonight]]

-- Get the background color from the 'Normal' highlight group
local normal_bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg

-- Apply it to TabLineSel. This keeps the foreground but fixes the background.
vim.api.nvim_set_hl(0, "TabLineSel", {
  bg = normal_bg,
})
