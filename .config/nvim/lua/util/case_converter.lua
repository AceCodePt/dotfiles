-- =============================================================================
-- Universal Case Converter
--
-- A Lua module for Neovim to convert visually selected text between
-- camelCase, PascalCase, snake_case, and kebab-case.
--
-- To use this, save it as a .lua file (e.g., `lua/util/case_converter.lua`)
-- and then create keymaps or commands to call the public functions.
--
-- =============================================================================

local M = {}

-- =============================================================================
-- SECTION 1: CORE LOGIC (PRIVATE IMPLEMENTATION)
-- All core functions are declared as 'local' to ensure they are available
-- to each other before being exposed on the public module table.
-- =============================================================================

--- Splits any string into a table of words.
-- @param str The input string.
-- @return A table of lowercase words.
local function get_words(str)
  -- This series of substitutions is designed to insert spaces as word boundaries.
  local s = str
      -- Add a space between an uppercase letter and a following uppercase letter
      -- that is itself followed by a lowercase letter (e.g., "HTMLParser" -> "HTML Parser").
      :gsub('([A-Z])([A-Z][a-z])', '%1 %2')
      -- Add a space between a lowercase letter or a digit and a following uppercase letter
      -- (e.g., "camelCase" -> "camel Case", "myVar1Value" -> "myVar1 Value").
      :gsub('([a-z0-9])([A-Z])', '%1 %2')
      -- Add a space between a letter and a following digit (e.g., "version1" -> "version 1").
      :gsub('([A-Za-z])([0-9])', '%1 %2')

  -- Replace underscores, hyphens, and newlines with spaces to normalize separators.
  s = s:gsub('[%s_\n-]', ' ')

  -- Split the string by one or more spaces and collect non-empty, lowercase words.
  local words = {}
  for word in s:gmatch('%S+') do
    table.insert(words, word:lower())
  end
  return words
end

--- Converts a string to PascalCase.
local function to_pascal_case(str)
  local words = get_words(str)
  local parts = {}
  for _, word in ipairs(words) do
    table.insert(parts, word:sub(1, 1):upper() .. word:sub(2))
  end
  return table.concat(parts, '')
end

--- Converts a string to camelCase.
local function to_camel_case(str)
  -- This function now safely calls the local `to_pascal_case` function.
  local pascal = to_pascal_case(str)
  if #pascal > 0 then
    return pascal:sub(1, 1):lower() .. pascal:sub(2)
  end
  return ''
end

--- Converts a string to snake_case.
local function to_snake_case(str)
  local words = get_words(str)
  return table.concat(words, '_')
end

--- Converts a string to kebab-case.
local function to_kebab_case(str)
  local words = get_words(str)
  return table.concat(words, '-')
end

--- Applies a given converter function to the current visual selection
-- and puts the result after the cursor.
local function _convert_selection(converter)
  local mode = vim.fn.mode()
  if not (mode:find('[vV\22]')) then
    print('Error: No visual selection.')
    return
  end

  -- 1. Grab the visually selected text using getregion.
  local selection_lines = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."))
  if not selection_lines or #selection_lines == 0 then
    return
  end
  local selection_text = table.concat(selection_lines, '\n')

  if selection_text == '' then
    return
  end

  local converted_text = converter(selection_text)

  -- Just paste it!
  vim.api.nvim_paste(converted_text, false, -1)
end

-- =============================================================================
-- SECTION 2: PUBLIC API FOR NEVIM
-- These are the functions you will call from your keymaps or commands.
-- We assign the local functions to the public 'M' table here.
-- =============================================================================

-- Expose individual conversion functions for direct use (e.g., by other plugins)
M.to_pascal_case = to_pascal_case
M.to_camel_case = to_camel_case
M.to_snake_case = to_snake_case
M.to_kebab_case = to_kebab_case

-- Expose selection converter functions for keymaps
function M.convert_selection_to_camel()
  _convert_selection(to_camel_case)
end

function M.convert_selection_to_pascal()
  _convert_selection(to_pascal_case)
end

function M.convert_selection_to_snake()
  _convert_selection(to_snake_case)
end

function M.convert_selection_to_kebab()
  _convert_selection(to_kebab_case)
end

return M
