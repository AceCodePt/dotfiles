local augroup = vim.api.nvim_create_augroup("UserBuf", { clear = true })

-- Disable auto comment
vim.api.nvim_create_autocmd("BufEnter", {
  group = augroup,
  callback = function()
    vim.opt.formatoptions = { c = false, r = false, o = false }
  end,
})


-- Return to last edit position when opening files
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup,
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})
