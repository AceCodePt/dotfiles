vim.filetype.add({
  extension = {
    tf = "terraform",
  },
})

vim.cmd([[silent! autocmd! filetypedetect BufRead,BufNewFile *.tf]])
vim.cmd([[autocmd BufRead,BufNewFile *.hcl set filetype=hcl]])
vim.cmd([[autocmd BufRead,BufNewFile .terraformrc,terraform.rc set filetype=hcl]])
vim.cmd([[autocmd BufRead,BufNewFile *.tf,*.tfvars set filetype=terraform]])
vim.cmd([[autocmd BufRead,BufNewFile *.tfstate,*.tfstate.backup set filetype=json]])

vim.cmd([[let g:terraform_fmt_on_save=1]])
vim.cmd([[let g:terraform_align=1]])


-- File: lua/utils/notify_filter.lua
-- Description:
-- A utility to globally filter vim.notify() messages based on a log level.
-- This overrides the default vim.notify and vim.log.set_level functions
-- to create a centralized notification management system.

local M = {}

-- =============================================================================
-- Configuration
-- =============================================================================

-- This table will hold the state, including the original functions and current level.
local state = {
  original_notify = vim.notify,
  original_set_level = vim.log.set_level,
  -- Set the initial desired log level.
  -- Any message with a level below this will be ignored by vim.notify.
  -- For example, INFO will show INFO, WARN, ERROR, but hide DEBUG.
  level = vim.log.levels.INFO,
}

-- =============================================================================
-- Core Functions
-- =============================================================================

--- A custom notify function that respects the configured log level.
-- @param message The message string.
-- @param level The vim.log.levels enum for the message.
-- @param opts Additional options for vim.notify.
local function filtered_notify(message, level, opts)
  -- If the message level is not provided, or if it is at or above
  -- our configured verbosity level, show the notification.
  if not level or level >= state.level then
    state.original_notify(message, level, opts)
  end
end

--- A custom set_level function that updates both our internal state and
-- the actual vim.log level for file logging.
-- @param level The vim.log.levels enum to set.
local function custom_set_level(level)
  -- Update our internal state for vim.notify filtering.
  state.level = level
  -- Call the original function to maintain file logging behavior.
  state.original_set_level(level)
  state.original_notify("Notification level set to: " .. vim.log.level_string(level), vim.log.levels.INFO)
end

-- =============================================================================
-- Public API
-- =============================================================================

--- Applies the overrides to the global vim functions.
-- This should be called once from your main configuration (e.g., init.lua).
function M.setup()
  -- Override the global functions with our custom, filtered versions.
  vim.notify = filtered_notify
  vim.log.set_level = custom_set_level

  -- Set the initial level for both our filter and the file logger.
  custom_set_level(state.level)

  print("Notification filter enabled. Current level: " .. vim.log.level_string(state.level))
end

return M
