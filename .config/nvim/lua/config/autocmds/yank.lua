
-- Basic autocommands
local augroup = vim.api.nvim_create_augroup("UserYank", {clear = true})

-- Highlight when yanking
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup,
  callback = function()
    vim.highlight.on_yank({ timeout = 80 })
  end,
})
