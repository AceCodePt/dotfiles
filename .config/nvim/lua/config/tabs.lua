local map = require("util.map").map


-- Mimic harpoon style
local tab_keys = { 'y', 'u', 'i', 'o', 'p', '[' }

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
    local tab_highlight_name = is_current_tab and "TabLineSel" or "TabLine"
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

  return table.concat(tabs, "") .. "%#TabLine#%T"
end

-- Set the global tabline option to use our function
vim.opt.tabline = "%!v:lua.get_custom_tabline()"

local function is_buffer_open_in_any_tab(win_id, buf_id)
  local tabpages = vim.api.nvim_list_tabpages()

  for _, tabpage_id in ipairs(tabpages) do
    local windows = vim.api.nvim_tabpage_list_wins(tabpage_id)

    for _, current_win_id in ipairs(windows) do
      local current_buf_id = vim.api.nvim_win_get_buf(current_win_id)

      if current_buf_id == buf_id and current_win_id ~= win_id then
        return true
      end
    end
  end

  -- 7. If the loops complete without finding a match, the buffer is not open
  return false
end

local function has_multiple_windows()
  -- 0 is the ID for the current tabpage
  local window_list = vim.api.nvim_tabpage_list_wins(0)

  -- The '#' operator in Lua gets the length of a list/table.
  local window_count = #window_list

  -- A tab has multiple windows (splits) if the count is > 1.
  return window_count > 1
end


map({ "n", "t" }, '<M-w>', function()
  -- Check if there is only one tab page open
  if vim.fn.tabpagenr('$') == 1 then
    vim.cmd.quit()
    return
  end

  local current_buf_id = vim.api.nvim_get_current_buf()
  local current_window_id = vim.api.nvim_get_current_win()

  -- Check if the current buffer is a terminal
  local buf_type = vim.api.nvim_get_option_value('buftype', { buf = current_buf_id })

  if buf_type == 'terminal' then
    local job_id = vim.b.terminal_job_id
    if not job_id then return end

    local jobwait = vim.fn.jobwait({ job_id }, 0)
    local running = jobwait[1] == -1
    if running then
      -- Send a signal to the terminal to terminate the process
      vim.api.nvim_chan_send(job_id, vim.keycode '<C-c>')
    end
  end

  if not has_multiple_windows() then
    vim.cmd.tabclose()
  end
  if not is_buffer_open_in_any_tab(current_window_id, current_buf_id) then
    vim.cmd('silent! bd! ' .. current_buf_id)
  end
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

for index, value in ipairs(tab_keys) do
  map({ "n", "t" }, '<M-' .. value:lower() .. '>', function()
    vim.cmd(index .. 'tabnext')
  end, { desc = 'Go to ' .. index .. ' tab' })

  map({ "n", "t" }, '<M-' .. value:upper() .. '>', swap_tab_positions(index), { desc = 'Move to ' .. index .. ' tab' })
end

local function go_to_definition_smart()
  -- Get the URI of the current buffer once at the start
  local current_uri = vim.uri_from_bufnr(0)

  local params = {
    textDocument = { uri = current_uri },
    position = {
      line = vim.api.nvim_win_get_cursor(0)[1] - 1,
      character = vim.api.nvim_win_get_cursor(0)[2],
    },
  }

  local result, err = vim.lsp.buf_request_sync(0, "textDocument/definition", params, 1000)

  if err or not result or vim.tbl_isempty(result) then
    vim.notify("Definition not found", vim.log.levels.WARN)
    return
  end

  local locations
  if result.result then
    locations = result.result
  else
    local _, inner_payload = next(result)
    if inner_payload and inner_payload.result then
      locations = inner_payload.result
    end
  end

  if not locations or vim.tbl_isempty(locations) then
    vim.notify("Definition not found (could not parse locations)", vim.log.levels.WARN)
    return
  end

  local location = vim.islist(locations) and locations[1] or locations

  if not location then
    vim.notify("Definition not found (invalid location data)", vim.log.levels.WARN)
    return
  end

  local target_uri, position
  if location.targetUri then
    target_uri = location.targetUri
    position = location.targetSelectionRange.start
  else
    target_uri = location.uri
    position = location.range.start
  end

  if not position then
    vim.notify("Definition not found (could not parse position)", vim.log.levels.WARN)
    return
  end

  -- NEW: Iterate through all open tabs to find a match
  for _, tab_handle in ipairs(vim.api.nvim_list_tabpages()) do
    local win_handle = vim.api.nvim_tabpage_get_win(tab_handle)
    local buf_handle = vim.api.nvim_win_get_buf(win_handle)

    -- Ensure the buffer is valid and has a file name before getting its URI
    if vim.api.nvim_buf_is_loaded(buf_handle) and vim.api.nvim_buf_get_name(buf_handle) ~= "" then
      local tab_uri = vim.uri_from_bufnr(buf_handle)

      if tab_uri == target_uri then
        -- If a match is found, switch to that tab and jump
        vim.api.nvim_set_current_tabpage(tab_handle)
        vim.api.nvim_win_set_cursor(0, { position.line + 1, position.character })
        return -- We're done, so exit the function
      end
    end
  end

  -- If the loop completes without finding a match, create a new tab
  local file_path = vim.uri_to_fname(target_uri)
  vim.cmd("tabedit " .. vim.fn.fnameescape(file_path))
  vim.api.nvim_win_set_cursor(0, { position.line + 1, position.character })
end

vim.keymap.set('n', 'gD', go_to_definition_smart, {
  noremap = true,
  silent = true,
  desc = "Go to definition (reuses tab if open)"
})
