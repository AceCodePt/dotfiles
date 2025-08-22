local map = require("util.map").map


local function copyDiagnosticUnderCursor(buf)
  local diagnostics = vim.diagnostic.get(buf, {
    lnum = vim.fn.line('.') - 1,
    col = vim.fn.col('.') - 1,
  })
  -- Check if any diagnostics were found
  if #diagnostics == 0 then
    print("No diagnostic under cursor")
    return
  end

  -- Format all diagnostic messages into a numbered list
  local messages = {}
  for i, d in ipairs(diagnostics) do
    table.insert(messages, string.format("%d. %s", i, d.message))
  end
  local formatted_message = table.concat(messages, "\n")

  -- Copy the formatted string to the system clipboard
  vim.fn.setreg('+', formatted_message)
  print("Copied all diagnostics to clipboard!")
end

-- LSP keymaps
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(event)
    local opts = { buffer = event.buf }

    -- Navigation
    map('n', 'gd', vim.lsp.buf.definition, opts)
    map('n', 'gs', vim.lsp.buf.declaration, opts)
    map('n', 'gr', vim.lsp.buf.references, opts)
    map('n', 'gi', vim.lsp.buf.implementation, opts)

    -- Information
    map('n', 'K', vim.lsp.buf.hover, opts)

    -- Code actions
    map('n', '<leader>ca', vim.lsp.buf.code_action, opts)
    map('n', '<leader>rn', vim.lsp.buf.rename, opts)

    -- Diagnostics
    map('n', 'gn', function()
      vim.diagnostic.jump({ count = 1, float = true })
    end
    , opts)
    map('n', 'gp', function()
      vim.diagnostic.jump({ count = -1, float = true })
    end
    , opts)
    map('n', '<leader>q', vim.diagnostic.setloclist, opts)
    map({ 'n', 'v' }, 'yd', function()
      copyDiagnosticUnderCursor(event.buf)
    end, opts)
    map({ 'n', 'v' }, '<leader>f', function()
      local ok, conform = pcall(require, "conform")
      if ok then
        conform.format()
      end
    end)
  end,
})
