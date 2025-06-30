
local augroup = vim.api.nvim_create_augroup("UserCmdLine", {})

-- only highlight when searching
vim.api.nvim_create_autocmd("CmdlineEnter", {
  group = augroup,
  callback = function()
    local cmd = vim.v.event.cmdtype
    if cmd == "/" or cmd == "?" then
      vim.opt.hlsearch = true
    end
  end,
})

-- only highlight when searching
vim.api.nvim_create_autocmd("CmdlineLeave", {
  group = augroup,
  callback = function()
    local cmd = vim.v.event.cmdtype
    if cmd == "/" or cmd == "?" then
      vim.opt.hlsearch = false
    end
  end,
})

