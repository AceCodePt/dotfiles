local M = {}

--- Simple utility for opening and running a terminal command
---@param command string
function M.open_and_run_terminal_command(command)
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

return M
