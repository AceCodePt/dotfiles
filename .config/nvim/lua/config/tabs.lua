local map = require("util.map").map

-- Tab display settings
vim.opt.showtabline = 2 -- Always show tabline (0=never, 1=when multiple tabs, 2=always)

function get_custom_tabline()
  local tabs = {}
  local devicons_ok, devicons = pcall(require, "nvim-web-devicons")

  local tab_handles = vim.api.nvim_list_tabpages()
  local current_tab_handle = vim.api.nvim_get_current_tabpage()

  for i, tab_handle in ipairs(tab_handles) do
    local is_current_tab = (tab_handle == current_tab_handle)
    -- CORRECTED: Use standard highlight logic
    local tab_highlight_name = is_current_tab and "TabLine" or "TabLineSel"
    local tab_highlight_str = "%#" .. tab_highlight_name .. "#"

    local win_handle = vim.api.nvim_tabpage_get_win(tab_handle)
    local bufnr = vim.api.nvim_win_get_buf(win_handle)

    local buf_name = vim.api.nvim_buf_get_name(bufnr)
    local file_name = vim.fn.fnamemodify(buf_name, ":t")
    local filetype = vim.bo[bufnr].filetype

    if file_name == "" then
      file_name = "[No Name]"
    end

    local tab_label = tab_highlight_str .. " %" .. i .. "T"

    if devicons_ok then
      local icon, icon_hl_group = devicons.get_icon(file_name, filetype, { default = true })
      tab_label = tab_label .. " %#" .. icon_hl_group .. "#" .. icon .. tab_highlight_str
    end

    tab_label = tab_label .. " " .. file_name .. "  "
    table.insert(tabs, tab_label)
  end

  return table.concat(tabs, "") .. "%#TabLineSel#%T"
end

-- Set the global tabline option to use our function
vim.opt.tabline = "%!v:lua.get_custom_tabline()"



map({ "n", "t" }, '<M-w>', function()
  -- Check if there is only one tab page open
  if vim.fn.tabpagenr('$') == 1 then
    vim.cmd.quit()
    return
  end

  local current_buf = vim.api.nvim_get_current_buf()

  -- Check if the current buffer is a terminal
  local buf_type = vim.api.nvim_get_option_value('buftype', { buf = current_buf })

  if buf_type == 'terminal' then
    -- Send a signal to the terminal to terminate the process
    vim.api.nvim_chan_send(vim.b[current_buf].terminal_job_id, vim.keycode '<C-c>')
  end

  vim.cmd.tabclose()
  vim.cmd('silent! bd! ' .. current_buf)
end, { desc = 'Close current tab' })

map({ "n", "t" }, '<M-t>', function()
  vim.cmd.tabnew()
  vim.cmd.term()
end, { desc = 'Create new tab with terminal' })

-- Go to the previous tab
map({ "n", "t" }, '<M-j>', vim.cmd.tabprevious, { desc = 'Go to previous tab' })

-- Go to the next tab
map({ "n", "t" }, '<M-k>', vim.cmd.tabnext, { desc = 'Go to next tab' })

-- Move the current tab one position to the left
map({ "n", "t" }, '<M-J>', function()
  vim.cmd.tabmove({ args = { '-1' } })
end, { desc = 'Move tab left' })

-- Move the current tab one position to the right
map({ "n", "t" }, '<M-K>', function()
  vim.cmd.tabmove({ args = { '+1' } })
end, { desc = 'Move tab right' })

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
