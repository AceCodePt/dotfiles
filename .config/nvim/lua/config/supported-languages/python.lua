local map = require("util.map").map

local M = {}

--- Extracts and cleans the function signature from the LSP hover response.
--- Instead of flattening the signature into one line, this version preserves
--- newlines and returns a table of strings, where each string is a line.
--- @param client vim.lsp.Client The LSP client object.
--- @param bufnr number The buffer number.
--- @return string | nil table of strings representing the lines of the signature, or nil.
function M.get_function_return_value(client, bufnr)
  -- Prepare and send the hover request to the LSP server.
  local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
  -- Use a reasonable timeout for the synchronous request.
  local response = client:request_sync("textDocument/hover", params, 2000, bufnr)

  -- Validate the response from the LSP server.
  if not response or not response.result or not response.result.contents then
    vim.notify("No information available from LSP hover.", vim.log.levels.WARN)
    return nil
  end
  -- vim.lsp.bug.hover

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
  local return_value = hover_value:gsub("^```[^\n]*[%s%S]*->%s", ""):gsub("\n```[%s%S]*$", "")

  if return_value then
    return return_value
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
function M.get_current_definition_range()
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
  --- @type TSNode
  local definition_node
  --- @type TSNode | nil
  local node = current_node
  while node do
    local node_type = node:type()
    -- Add other language-specific definition types if needed.
    if node_type == 'function_definition' then
      definition_node = node
      break
    end
    node = node:parent()
  end


  if not definition_node then
    vim.notify("Could not find a parent function or class definition.", vim.log.levels.WARN)
    return nil
  end



  local parameters_node = definition_node:field("parameters")[1]

  if not parameters_node then
    vim.notify("Couldn't find the parameters node", vim.log.levels.ERROR)
    return nil
  end



  --- @type TSNode | nil
  local first_item_before_colon = parameters_node
  while true do
    if not first_item_before_colon then
      vim.notify("Didn't find next sibiling for some reason on line continuation", vim.log.levels.ERROR)
      return nil
    end
    if first_item_before_colon:type() == "block" or first_item_before_colon:type() == "comment" then
      first_item_before_colon = first_item_before_colon:prev_sibling()
      break
    end
    first_item_before_colon = first_item_before_colon:next_sibling()
  end


  if not first_item_before_colon then
    vim.notify("Couldn't find the end of the function signature", vim.log.levels.ERROR)
    return nil
  end


  local _, _, start_row, start_col = parameters_node:range()
  local _, _, end_row, end_col = first_item_before_colon:range()

  return {
    start = { line = start_row, character = start_col },
    ['end'] = { line = end_row, character = end_col },
  }
end

return {
  fts = "python",
  treesitter = "python",
  formatters = { "ruff" },
  lsp = {
    name = "pyright",
    config = {
      filetypes = { "python" },
      settings = {
        python = {
          pythonPath = (function()
            local venv = vim.fn.findfile(".venv/bin/python", vim.fn.getcwd() .. ";")
            if venv ~= "" then
              return venv
            end
            return vim.fn.exepath("python3")
          end)(),
        },
      },
      on_attach = function(client, bufnr)
        map("n", "<leader>m", function()
          -- 1. Get the signature from the LSP as a table of lines.
          local function_return_value = M.get_function_return_value(client, bufnr)
          if not function_return_value then
            return
          end

          -- 2. Get the range in the buffer that needs to be replaced.
          local replacement_range = M.get_current_definition_range()
          if not replacement_range then
            return
          end


          -- 3. Prepare and apply the text edit.
          local text_edit = {
            range = replacement_range,
            newText = " -> " .. function_return_value .. ":"
          }

          vim.lsp.util.apply_text_edits({ text_edit }, bufnr, client.offset_encoding)
        end, { desc = "Get signature from hover and replace", buffer = bufnr })
      end
    }
  },
}
