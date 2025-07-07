-- =============================================================================
-- Universal Case Converter
--
-- A Lua module for Neovim to convert visually selected text between
-- camelCase, PascalCase, snake_case, and kebab-case.
--
-- To use this, save it as a .lua file (e.g., `lua/utils/case_converter.lua`)
-- and then create keymaps or commands to call the public functions.
--
-- local converter = require('utils.case_converter')
-- vim.keymap.set('v', '<leader>cc', converter.convert_selection_to_camel, { desc = 'Convert to camelCase' })
-- vim.keymap.set('v', '<leader>cp', converter.convert_selection_to_pascal, { desc = 'Convert to PascalCase' })
-- vim.keymap.set('v', '<leader>cs', converter.convert_selection_to_snake, { desc = 'Convert to snake_case' })
-- vim.keymap.set('v', '<leader>ck', converter.convert_selection_to_kebab, { desc = 'Convert to kebab-case' })
-- =============================================================================

local M = {}

-- =============================================================================
-- SECTION 1: CORE LOGIC
-- =============================================================================

--- Splits any string into a table of words.
-- This is the core of the module. It intelligently handles various formats:
-- - "kebab-case"
-- - "snake_case"
-- - "PascalCase"
-- - "camelCase"
-- - "UPPER_CASE_SNAKE"
-- - "space separated"
-- - "HTMLParser" -> {"html", "parser"}
--- @param str string The input string.
--- @return table of lowercase words.
local function _get_words(str)
  -- Add a space before any uppercase letter that is followed by a lowercase letter.
  -- This handles cases like "PascalCase" -> "Pascal Case" and "HTMLParser" -> "HTML Parser".
  local s = str:gsub('([A-Z])([A-Z][a-z])', '%1 %2')
      :gsub('([a-z])([A-Z])', '%1 %2')

  -- Replace underscores, hyphens, and newlines with spaces to normalize separators.
  s = s:gsub('[%s_\n-]', ' ')

  -- Split the string by one or more spaces and collect non-empty words.
  local words = {}
  for word in s:gmatch('%S+') do
    table.insert(words, word:lower())
  end
  return words
end

-- =============================================================================
-- SECTION 2: CASE CONVERSION FUNCTIONS
-- These functions take a string, use _get_words() to deconstruct it,
-- and then reconstruct it in the target case.
-- =============================================================================

--- Converts a string to PascalCase.
-- e.g., "hello world" -> "HelloWorld"
local function to_pascal_case(str)
  local words = _get_words(str)
  local parts = {}
  for _, word in ipairs(words) do
    table.insert(parts, word:sub(1, 1):upper() .. word:sub(2))
  end
  return table.concat(parts, '')
end

--- Converts a string to camelCase.
-- e.g., "hello world" -> "helloWorld"
local function to_camel_case(str)
  local pascal = M.to_pascal_case(str)
  if #pascal > 0 then
    return pascal:sub(1, 1):lower() .. pascal:sub(2)
  end
  return ''
end

--- Converts a string to snake_case.
-- e.g., "Hello World" -> "hello_world"
local function to_snake_case(str)
  local words = _get_words(str)
  return table.concat(words, '_')
end

--- Converts a string to kebab-case.
-- e.g., "Hello World" -> "hello-world"
local function to_kebab_case(str)
  local words = _get_words(str)
  return table.concat(words, '-')
end

-- =============================================================================
-- SECTION 3: GENERIC SELECTION HANDLER
-- This function handles the Neovim-specific logic of getting the visual
-- selection and replacing it with the converted text.
-- =============================================================================

--- Applies a given converter function to the current visual selection.
-- This function handles all visual modes (v, V, and Ctrl-V block mode)
-- and replaces the selected text with the result of the conversion.
-- @param converter A function that takes a string and returns a converted string.
local function _convert_selection(converter)
  local mode = vim.fn.mode()
  if not (mode:find('[vV\22]')) then
    print('Error: No visual selection.')
    return
  end

  -- Get selection positions and normalize them to handle upward selection.
  local pos1 = vim.fn.getpos("'<")
  local pos2 = vim.fn.getpos("'>")
  local start_pos, end_pos
  if pos1[2] > pos2[2] or (pos1[2] == pos2[2] and pos1[3] > pos2[3]) then
    start_pos, end_pos = pos2, pos1
  else
    start_pos, end_pos = pos1, pos2
  end
  local start_line, start_col = start_pos[2], start_pos[3]
  local end_line, end_col = end_pos[2], end_pos[3]

  -- For block selections, process each line independently.
  if mode == '\22' then -- Check for block mode (Ctrl-V)
    local new_lines = {}
    local lines_to_change = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
    for _, line in ipairs(lines_to_change) do
      -- Ensure column selection is within the bounds of the current line.
      local actual_end_col = math.min(end_col, #line)
      local actual_start_col = math.min(start_col, #line + 1)

      if actual_end_col < actual_start_col then
        table.insert(new_lines, line) -- Selection is outside line content.
      else
        local prefix = line:sub(1, actual_start_col - 1)
        local middle = line:sub(actual_start_col, actual_end_col)
        local suffix = line:sub(actual_end_col + 1)
        table.insert(new_lines, prefix .. converter(middle) .. suffix)
      end
    end
    vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, new_lines)
  else -- Handle normal (v) and line (V) visual modes.
    local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
    if not lines or #lines == 0 then
      return
    end

    local selection_text
    if start_line == end_line then
      selection_text = lines[1]:sub(start_col, end_col)
    else
      local parts = {}
      table.insert(parts, lines[1]:sub(start_col))
      for i = 2, #lines - 1 do
        table.insert(parts, lines[i])
      end
      table.insert(parts, lines[#lines]:sub(1, end_col))
      selection_text = table.concat(parts, '\n')
    end

    local converted_text = converter(selection_text)

    -- Split the result by newlines for nvim_buf_set_text.
    local replacement_lines = {}
    for line in converted_text:gmatch('([^\n]*)') do
      table.insert(replacement_lines, line)
    end
    vim.api.nvim_buf_set_text(0, start_line - 1, start_col - 1, end_line - 1, end_col, replacement_lines)
  end
end

-- =============================================================================
-- SECTION 4: PUBLIC API FOR NEVIM
-- These are the functions you will call from your keymaps or commands.
-- =============================================================================

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
