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

-- Helper function to open a terminal and execute a command
local function open_and_run_terminal_command(command)
  vim.cmd('tabnew')
  -- Open the terminal in the new split and execute the command
  -- The 'term://' prefix indicates a terminal buffer
  -- The command after 'term://' will be executed immediately.
  vim.cmd('terminal ' .. command)
  -- Optional: Go back to normal mode after the command runs
  -- This is often preferred if the command is short-lived.
  -- If you want to interact with the terminal after, remove this line.
  -- vim.cmd('startinsert') -- If you want to be in insert mode
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-\\><C-N>", true, true, true), 'n', false)
end

-- Made vim enter with some sick npm commands
vim.api.nvim_create_autocmd("VimEnter", {
  group = augroup,
  callback = function()
    local res = vim.fs.find("package.json", { limit = 1, type = "file" })
    if res == nil or res[1] == nil then
      return
    end

    map('n', '<leader>nd', function()
      open_and_run_terminal_command('nr dev')
    end, { desc = "[N]PM [D]ev" })

    map('n', '<leader>ns', function()
      open_and_run_terminal_command('nr start')
    end, { desc = "[N]PM [S]tart" })

    map('n', '<leader>ni', function()
      open_and_run_terminal_command('ni')
    end, { desc = "[N]PM [I]nstall" })
  end,
})
