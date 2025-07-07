local M = {}


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

return M
