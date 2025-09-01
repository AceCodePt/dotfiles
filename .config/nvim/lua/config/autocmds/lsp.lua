local map = require("util.map").map
local tmux_popup = require("util.fzf_tmux").tmux_popup


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
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    local bufnr = args.buf
    local opts = { buffer = bufnr }

    -- Unset 'formatexpr'
    vim.bo[bufnr].formatexpr = nil
    -- Unset 'omnifunc'
    vim.bo[bufnr].omnifunc = nil

    -- Navigation
    map('n', 'gd', vim.lsp.buf.definition, opts)
    map('n', 'gs', vim.lsp.buf.declaration, opts)
    map('n', 'gr', vim.lsp.buf.references, opts)
    map('n', 'gi', vim.lsp.buf.implementation, opts)

    -- Information
    map('n', 'K', vim.lsp.buf.hover, opts)

    -- Code actions
    map('n', '<leader>ca',
      function()
        ---@type any
        local params = vim.lsp.util.make_range_params(0, "utf-8")
        params.context = {
          triggerKind = vim.lsp.protocol.CodeActionTriggerKind.Invoked,
          diagnostics = vim.diagnostic.get(bufnr)
        }
        local code_action_result = client:request_sync('textDocument/codeAction', params, 2000, bufnr)

        if not code_action_result then
          return
        end

        local err = code_action_result.err
        local results = code_action_result.result

        if err then
          vim.notify("Error fetching code actions: " .. err.message, vim.log.levels.ERROR)
          return
        end

        if results == nil or vim.tbl_isempty(results) then
          vim.notify("No code actions available.", vim.log.levels.INFO)
          return
        end
        results = vim.iter(results)
            :filter(function(item)
              return not item.disabled
            end)
            :totable()
        local actions = vim.iter(ipairs(results))
            :map(function(index, item)
              return index .. ") " .. item.title
            end)
            :totable()

        local selected_item = tmux_popup(actions, { fzf = true, prompt = "Code Action > " })

        if selected_item == "" then
          return
        end

        local index = tonumber(string.match(selected_item, "^%d+"))
        local selected_action = results[index].command
        client:exec_cmd(selected_action, { bufnr = bufnr })
      end
      , opts)

    -- rename
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
      copyDiagnosticUnderCursor(args.buf)
    end, opts)
    map({ 'n', 'v' }, '<leader>f', function()
      local ok, conform = pcall(require, "conform")
      if ok then
        conform.format()
      else
        -- Fallback to regular format
        vim.lsp.buf.format()
      end
    end)
  end,
})
