local map = require("util.map").map

-- Tab display settings
vim.opt.showtabline = 1 -- Always show tabline (0=never, 1=when multiple tabs, 2=always)
vim.opt.tabline = ''    -- Use default tabline (empty string uses built-in)

-- Transparent tabline appearance
vim.cmd([[
  hi TabLineFill guibg=NONE ctermfg=242 ctermbg=NONE
]])

local function bypass_terminal(command)
  return function()
    vim.cmd(command)
  end
end

map({ "n", "t" }, '<M-w>', bypass_terminal('tabclose'), { desc = 'Close current tab' })
map({ "n", "t" }, '<M-t>', bypass_terminal('tabnew | term'), { desc = 'Create new tab with terminal' })
map({ "n", "t" }, '<M-j>', bypass_terminal('tabprevious'), { desc = 'Go to previous tab' })
map({ "n", "t" }, '<M-k>', bypass_terminal('tabnext'), { desc = 'Go to next tab' })
map({ "n", "t" }, '<M-J>', bypass_terminal('-tabmove'), { desc = 'Move to previous tab' })
map({ "n", "t" }, '<M-K>', bypass_terminal('+tabmove'), { desc = 'Go to next tab' })

-- Function to swap the positions of two Neovim tab pages
--- @param tab1_num number: The current display number of the first tab page to swap (1-indexed).
local function swap_tab_positions(tab1_num)
  return function()
    local tab2_num = vim.fn.tabpagenr()
    local total_tabs = vim.fn.tabpagenr('$')

    if tab1_num < 1 then
      tab1_num = 1
    end

    if tab1_num > total_tabs then
      tab1_num = total_tabs
    end

    if tab1_num == tab2_num then
      return
    end

    local all_tab_ids_initial = vim.api.nvim_list_tabpages()
    local id_at_tab1_num = all_tab_ids_initial[tab1_num]
    local id_at_tab2_num = all_tab_ids_initial[tab2_num]
    if tab1_num == 1 then
      tab1_num = 0
    end
    vim.api.nvim_set_current_tabpage(id_at_tab1_num)
    vim.cmd(string.format("%dtabmove", tab2_num))
    vim.api.nvim_set_current_tabpage(id_at_tab2_num)
    vim.cmd(string.format("%dtabmove", tab1_num))
  end
end

-- Mimic harpoon style
local tab_keys = { 'u', 'i', 'o', 'p' }
for index, value in ipairs(tab_keys) do
  map({ "n", "t" }, '<M-' .. value:lower() .. '>', ':' .. index .. 'tabnext<CR>', { desc = 'Go to ' .. index .. ' tab' })

  map({ "n", "t" }, '<M-' .. value:upper() .. '>', swap_tab_positions(index), { desc = 'Move to ' .. index .. ' tab' })
end
