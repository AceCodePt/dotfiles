local map = require("util.map").map

map('n', '<M-g>', function()
  -- Get the current working directory from Neovim
  local cwd = vim.fn.getcwd()
  -- Build the full tmux command with the correct directory
  local command = 'tmux display-popup -d '
      .. vim.fn.shellescape(cwd)
      .. ' -w100% -h100% -E lazygit'
  -- Run the command
  vim.fn.system(command)
end, { desc = 'Open lazygit in tmux popup' })
