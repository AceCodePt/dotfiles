-- File: lua/my_lsp_utils/init.lua (Corrected)
-- Description:
-- This Neovim utility provides functionality to replace a function's signature
-- with the signature provided by the Language Server Protocol (LSP).
-- It correctly handles multi-line signatures by preserving their formatting.

local M = {}

--- Extracts and cleans the function signature from the LSP hover response.
-- Instead of flattening the signature into one line, this version preserves
-- newlines and returns a table of strings, where each string is a line.
-- @param client The LSP client object.
-- @param bufnr The buffer number.
-- @return A table of strings representing the lines of the signature, or nil.
function M.get_function_signature_lines(client, bufnr)
  -- Prepare and send the hover request to the LSP server.
  local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
  -- Use a reasonable timeout for the synchronous request.
  local response = client:request_sync("textDocument/hover", params, 2000, bufnr)

  -- Validate the response from the LSP server.
  if not response or not response.result or not response.result.contents then
    vim.notify("No information available from LSP hover.", vim.log.levels.WARN)
    return nil
  end

  -- This handles different formats of hover content across Neovim versions.
  local hover_value
  if type(response.result.contents) == 'string' then
    hover_value = response.result.contents
  elseif type(response.result.contents) == 'table' then
    if response.result.contents.value then
      -- Handles { kind = 'markdown', value = '...' } structure
      hover_value = response.result.contents.value
    else
      -- Handles array of strings or marked strings
      local content_parts = {}
      for _, part in ipairs(response.result.contents) do
        if type(part) == 'string' then
          table.insert(content_parts, part)
        elseif type(part) == 'table' and part.value then
          table.insert(content_parts, part.value)
        end
      end
      hover_value = table.concat(content_parts, '\n')
    end
  end

  if not hover_value or hover_value == "" then
    vim.notify("Hover content is empty.", vim.log.levels.WARN)
    return nil
  end


  -- Process the signature as a multi-line block.
  -- 1. Remove the markdown code block fences (e.g., ```python ... ```).
  local cleaned_signature = hover_value:gsub("^```[^\n]*\n", ""):gsub("\n```$", "")

  -- Remove the (function) or (method) prefix from the hover info.
  cleaned_signature = cleaned_signature:gsub("^%s*%([%w_]+%)%s*", "")

  -- 2. Split the cleaned signature into a table of lines.
  local lines = {}
  for line in cleaned_signature:gmatch("([^\n]*)") do
    -- Trim leading/trailing whitespace from each line to keep formatting clean.
    -- Wrap gsub in parentheses to select its first return value.
    table.insert(lines, (line:gsub("^%s*(.-)%s*$", "%1")))
  end

  -- Remove any blank lines that might have resulted from the split.
  local cleaned_lines = {}
  for _, line in ipairs(lines) do
    if line ~= "" then
      table.insert(cleaned_lines, line)
    end
  end

  if #cleaned_lines > 0 then
    return cleaned_lines
  else
    vim.notify("Cleaned signature is empty after processing.", vim.log.levels.WARN)
    return nil
  end
end

--- Finds the range of the current function/class definition's signature.
-- This uses Treesitter to find the entire definition and then calculates the
-- end of the signature, which is typically the colon ':' before the body.
-- @param bufnr The buffer number.
-- @return A table representing the start and end position for replacement, or nil.
function M.get_current_definition_range(bufnr)
  -- Ensure nvim-treesitter is available.
  if not pcall(require, "nvim-treesitter.ts_utils") then
    vim.notify("nvim-treesitter is not available.", vim.log.levels.ERROR)
    return nil
  end
  local ts_utils = require("nvim-treesitter.ts_utils")

  local current_node = ts_utils.get_node_at_cursor(0)
  if not current_node then
    vim.notify("Could not find tree-sitter node at cursor.", vim.log.levels.WARN)
    return nil
  end

  -- Traverse up the syntax tree to find the containing function or class definition.
  local definition_node
  --- @type TSNode | nil
  local node = current_node
  while node do
    local node_type = node:type()
    -- Add other language-specific definition types if needed.
    if node_type == 'function_definition' or node_type == 'class_definition' then
      definition_node = node
      break
    end
    node = node:parent()
  end

  if definition_node then
    local start_row, start_col, def_end_row, _ = definition_node:range()
    local last_known_colon = nil

    -- Find the body by iterating children and checking their node type.
    -- This is more robust than using field names, which can fail on older APIs.
    local body_node = nil
    for child in definition_node:iter_children() do
      -- For Python, the body is a 'block'. This may need adjustment for other languages.
      if child:type() == "block" then
        body_node = child
        break
      end
    end

    local search_end_row = def_end_row
    if body_node then
      -- The signature must end on or before the line where the body starts.
      search_end_row, _, _, _ = body_node:range()
    end

    for r = start_row, search_end_row do
      local line_text = vim.api.nvim_buf_get_lines(bufnr, r, r + 1, true)[1]
      local search_start = 1
      while true do
        local colon_pos = line_text:find(":", search_start, true)
        if not colon_pos then break end

        -- If we are on the same line as the body, ensure the colon is before it.
        if body_node and r == search_end_row then
          local _, body_start_col, _, _ = body_node:range()
          if colon_pos >= body_start_col then
            break
          end
        end
        -- Store this colon and keep searching for a later one on the same line or subsequent lines.
        last_known_colon = { line = r, character = colon_pos }
        search_start = colon_pos + 1
      end
    end

    if last_known_colon then
      return {
        start = { line = start_row, character = start_col },
        ['end'] = last_known_colon,
      }
    end
  end


  vim.notify("Could not find a parent function or class definition.", vim.log.levels.WARN)
  return nil
end

--- Initializes the keymap to trigger the signature replacement.
-- This function is called by the LSP on_attach setup.
function M.init(client, bufnr)
  vim.keymap.set("n", "<leader>m", function()
    -- 1. Get the signature from the LSP as a table of lines.
    local signature_lines = M.get_function_signature_lines(client, bufnr)
    if not signature_lines then
      vim.notify("Failed to get signature from hover.", vim.log.levels.ERROR)
      return
    end

    -- 2. Get the range in the buffer that needs to be replaced.
    local replacement_range = M.get_current_definition_range(bufnr)
    if not replacement_range then
      vim.notify("Could not determine the definition range to replace.", vim.log.levels.ERROR)
      return
    end


    -- Reconstruct the signature with newlines.
    local new_text = table.concat(signature_lines, "\n")

    -- The LSP hover doesn't provide it, but it's required for valid syntax.
    new_text = new_text .. ":"

    -- 3. Prepare and apply the text edit.
    local text_edit = {
      range = replacement_range,
      newText = new_text,
    }

    vim.lsp.util.apply_text_edits({ text_edit }, bufnr, client.offset_encoding)
  end, { desc = "Get signature from hover and replace", buffer = bufnr })
end

return M
