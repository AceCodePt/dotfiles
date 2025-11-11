local M = {}

--- Simple utility for opening and running a terminal command
---@param command string
---@param params { location?: "start"|"next"|"prev"|"end", unfocus?: boolean, exit_on_success?: boolean }|nil Options table
function M.open_and_run_terminal_command(command, params)
  -- Ensure params is a table, even if nil is passed
  params = params or {}

  -- Get all parameters, setting defaults
  local location = params.location or 'next'
  local unfocus = params.unfocus == true
  local exit_on_success = params.exit_on_success == true

  -- 1. Store the original tabpage handle
  local original_tab = vim.api.nvim_get_current_tabpage()

  -- 2. Determine the correct vim command for tab creation
  local tab_cmd
  if location == 'start' then
    tab_cmd = '0tabnew'
  elseif location == 'prev' then
    tab_cmd = '-tabnew'
  elseif location == 'end' then
    tab_cmd = '$tabnew'
  else
    tab_cmd = 'tabnew'
  end

  -- 3. Create the new tab at the specified location
  vim.cmd(tab_cmd)

  -- 4. Get the buffer number that will host the terminal
  local term_bufnr = vim.api.nvim_get_current_buf()

  -- 5. Open the terminal and run the command
  if exit_on_success then
    -- If we need to auto-close, we must use termopen() to get the exit callback
    local on_exit_callback = function(job_id, exit_code, event)
      if exit_code == 0 then
        -- Schedule the buffer delete to run safely in the main loop
        vim.schedule(function()
          -- Check if buffer still exists before trying to delete
          if vim.api.nvim_buf_is_valid(term_bufnr) then
            vim.api.nvim_buf_delete(term_bufnr, { force = false })
          end
        end)
      end
    end
    
    -- termopen starts the job in the *current* buffer
    vim.fn.termopen(command, { on_exit = on_exit_callback })
  else
    -- Otherwise, the simple vim.cmd is fine
    vim.cmd('terminal ' .. command)
  end

  -- 6. Go back to normal mode from terminal mode
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-\\><C-N>", true, true, true), 'n', false)

  -- 7. If unfocus=true, switch back to the original tab
  if unfocus then
    vim.api.nvim_set_current_tabpage(original_tab)
  end
end

return M
