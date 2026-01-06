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

-- Create directories when saving files
vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup,
  callback = function()
    if vim.bo.filetype == "oil" or vim.api.nvim_buf_get_name(0) == "" then
      return
    end
    local dir = vim.fn.expand('<afile>:p:h')
    if vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, 'p')
    end
  end,
})

-- Configuration
local config = {
  debounce_ms = 0, -- Delay before speaking (prevents spam while scrolling)
}

local speak_group = vim.api.nvim_create_augroup("SpeakAccessibility", { clear = true })
local timer = assert(vim.uv.new_timer(), "Timer creation failed")

-- Helper: Send text to the 'speak' CLI
local function say(text)
  if not text or text:match("^%s*$") then return end

  -- 1. Shellescape the text so special characters don't break the shell
  local safe_text = vim.fn.shellescape(text)

  -- 2. Run inside an interactive zsh shell (-i) to load aliases
  local cmd = {
    "zsh",
    "-i",
    "-c",
    "speak " .. safe_text
  }

  -- 3. Detach prevents Neovim from freezing while zsh loads
  vim.fn.jobstart(cmd, { detach = true })
end

-- Helper: Debounce function to wait for cursor to settle
local function debounce_speak(callback)
  timer:stop()
  timer:start(config.debounce_ms, 0, vim.schedule_wrap(callback))
end

-- 3. VISUAL MODE: Speak Selection (Debounced)
vim.api.nvim_create_autocmd({ "CursorMoved", "ModeChanged" }, {
  group = speak_group,
  callback = function()
    -- Use schedule to capture the state after the movement event fully resolves
    vim.schedule(function()
      local mode = vim.api.nvim_get_mode().mode

      -- Check if we are in any Visual mode
      if not mode:match("^[vV\22]") then
        local cursor = vim.api.nvim_win_get_cursor(0)
        local row = cursor[1] - 1
        local col = cursor[2]

        local diagnostics = vim.diagnostic.get(0, { lnum = row })

        for _, diag in ipairs(diagnostics) do
          if col >= diag.col and col < diag.end_col then
            local severity_map = {
              [vim.diagnostic.severity.ERROR] = "Error",
              [vim.diagnostic.severity.WARN]  = "Warning",
              [vim.diagnostic.severity.INFO]  = "Info",
              [vim.diagnostic.severity.HINT]  = "Hint",
            }
            local type = severity_map[diag.severity] or "Diagnostic"
            say(type .. ": " .. diag.message)
          end
        end
      end

      -- Debounce: Only speak if the user stops expanding selection for X ms
      debounce_speak(function()
        -- Double check we are still in visual mode after the timer
        if not vim.api.nvim_get_mode().mode:match("^[vV\22]") then return end

        local start_pos = vim.fn.getpos("v")
        local end_pos = vim.fn.getpos(".")

        -- Get region allows us to grab block selections correctly
        local lines = vim.fn.getregion(start_pos, end_pos, { type = mode })
        local message = table.concat(lines, " ")

        say(message)
      end)
    end)
  end,
})
