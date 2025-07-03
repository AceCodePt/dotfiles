-- Description:
-- A utility to globally filter vim.notify() messages based on a log level.
-- This overrides the default vim.notify and vim.log.set_level functions
-- to create a centralized notification management system.

---@class NotifyFilter
local M = {}

-- =============================================================================
-- Type Definitions
-- =============================================================================

--- An alias for the possible log level values from vim.log.levels.
--- By defining this once, we can reuse it for better maintainability.
---@alias LogLevel 0|1|2|3|4

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
---@param message any The message string.
---@param level? LogLevel The vim.log.levels enum for the message.
---@param opts? table Additional options for vim.notify.
local function filtered_notify(message, level, opts)
  -- If the message level is not provided, or if it is at or above
  -- our configured verbosity level, show the notification.
  if not level or level >= state.level then
    state.original_notify(message, level, opts)
  end
end

--- A custom set_level function that updates both our internal state and
-- the actual vim.log level for file logging.
---@param level LogLevel The vim.log.levels enum to set.
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
---@param level? LogLevel An optional vim.log.levels enum to set the initial level.
function M.setup(level)
  -- Override the global functions with our custom, filtered versions.
  vim.notify = filtered_notify
  vim.log.set_level = custom_set_level

  -- Set the initial level for both our filter and the file logger.
  -- Use the provided level, or fall back to the default in the state table.
  custom_set_level(level or state.level)

  print("Notification filter enabled. Current level: " .. vim.log.level_string(state.level))
end

return M
