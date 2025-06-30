local map = require("util.map").map
local augroup = vim.api.nvim_create_augroup("UserTerminal", { clear = true })

-- This is a better coping mechnizem for copy
vim.api.nvim_create_autocmd({ "TextYankPost" }, {
  group = augroup,
  pattern = "term://*",
  callback = function()
    local width = vim.api.nvim_win_get_width(0) - 2
    local offset = vim.api.nvim_win_get_cursor(0)[2]
    local yanked_text = vim.fn.getreg("+")
    local new_str = ""
    local count = 1
    while true do
      local next_index = string.find(yanked_text, "\n", count)
      if next_index == nil then
        new_str = new_str .. string.sub(yanked_text, count, string.len(yanked_text))
        break
      end
      if next_index - count + offset >= width then
        new_str = new_str .. string.sub(yanked_text, count, next_index - 1)
      else
        new_str = new_str .. string.sub(yanked_text, count, next_index)
      end
      count = next_index + 1
      offset = 0
    end
    vim.fn.setreg("+", new_str)
  end,
})

-- Disable line numbers in terminal
vim.api.nvim_create_autocmd("TermOpen", {
  group = augroup,
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
  end,
})

-- Auto-close terminal when process exits
vim.api.nvim_create_autocmd("TermClose", {
  group = augroup,
  callback = function()
    if vim.v.event.status == 0 then
      vim.api.nvim_buf_delete(0, {})
    end
  end,
})


-- Made vim enter with some sick npm commands
vim.api.nvim_create_autocmd("VimEnter", {
  group = augroup,
  callback = function()
    local res = vim.fs.find("package.json", { limit = 1, type = "file" })
    if res == nil or res[1] == nil then
      return
    end

    map("n", "<leader>ni", ":TermExec cmd='ni' go_back=0<cr>", { desc = "[I]nstall" })
    map("n", "<leader>nd", ":TermExec cmd='nr dev' go_back=0<cr>", { desc = "[D]ev" })
    map("n", "<leader>ns", ":TermExec cmd='nr start' go_back=0<cr>", { desc = "[S]tart" })
  end,
})
