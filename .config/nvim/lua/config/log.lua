-- File: lua/utils/notify_filter.lua
-- Description:
-- A utility to globally filter vim.notify() messages based on a log level.
-- This overrides the default vim.notify function to create a centralized
-- notification management system.

---@class NotifyFilter
local M = {}

-- =============================================================================
-- Type Definitions
-- =============================================================================

--- An alias for the possible log level values, accepting numbers or strings.
--- By defining this once, we can reuse it for better maintainability.
---@alias LogLevel 0|1|2|3|4|"TRACE"|"DEBUG"|"INFO"|"WARN"|"ERROR"

-- =============================================================================
-- Configuration & State
-- =============================================================================

-- This table will hold the state, including the original notify function and current level.
local state = {
  original_notify = vim.notify,
  -- Set the initial desired log level.
  -- Any message with a level below this will be ignored by vim.notify.
  -- For example, INFO will show INFO, WARN, ERROR, but hide DEBUG.
  level = vim.log.levels.INFO,
}

-- Create lookup tables to convert between string and number levels.
local string_to_level = {}
local level_to_string_map = {}
for key, value in pairs(vim.log.levels) do
  if type(key) == 'string' and type(value) == 'number' then
    string_to_level[key] = value
    level_to_string_map[value] = key
  end
end

-- =============================================================================
-- Core Functions
-- =============================================================================

--- Converts a numeric log level to its string representation.
---@param level_num number The numeric log level.
---@return string The string representation (e.g., "INFO").
local function level_to_string(level_num)
  return level_to_string_map[level_num] or "UNKNOWN"
end

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

-- =============================================================================
-- Public API
-- =============================================================================

--- Sets the verbosity level for UI notifications.
---@param level LogLevel The vim.log.levels enum or string to set.
---@param silent boolean? should this function notify on change
function M.set_level(level, silent)
  local numeric_level

  if type(level) == 'string' then
    -- Convert string to number, case-insensitively.
    numeric_level = string_to_level[level:upper()]
    if not numeric_level then
      state.original_notify("Invalid log level string: " .. level, vim.log.levels.ERROR)
      return
    end
  elseif type(level) == 'number' then
    numeric_level = level
  else
    state.original_notify("Invalid log level type: " .. type(level), vim.log.levels.ERROR)
    return
  end

  state.level = numeric_level
  if not silent then
    state.original_notify("Notification level set to: " .. level_to_string(numeric_level), vim.log.levels.INFO)
  end
end

--- Applies the override to the global vim.notify function.
-- This should be called once from your main configuration (e.g., init.lua).
---@param level? LogLevel An optional vim.log.levels enum or string to set the initial level.
function M.setup(level)
  -- Override the global function with our custom, filtered version.
  vim.notify = filtered_notify

  -- Set the initial level for our filter.
  -- Use the provided level, or fall back to the default in the state table.
  M.set_level(level or state.level, true)
end

return M
