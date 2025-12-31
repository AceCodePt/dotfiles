local map = require("util.map").map
local tmux_popup = require("util.fzf_tmux").tmux_popup
local format = require("util.format").format


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

local function apply_action(act, cid, bufnr)
  local client = vim.lsp.get_client_by_id(cid)
  if not client then return end

  -- Check if the action needs resolving (common for vtsls refactors)
  if not act.edit and act.data then
    client:request('codeAction/resolve', act, function(err, resolved_act)
      if err then
        vim.notify("Failed to resolve action: " .. err.message, vim.log.levels.ERROR)
        return
      end
      -- Recursively call apply_action with the now-resolved action
      apply_action(resolved_act or act, cid)
    end)
    return
  end

  if act.edit then
    vim.lsp.util.apply_workspace_edit(act.edit, client.offset_encoding)
  end

  if act.command then
    local command = type(act.command) == "table" and act.command or act
    local fn = client.commands[command.command] or vim.lsp.commands[command.command]
    if fn then
      fn(command, { bufnr = bufnr })
    else
      client:request('workspace/executeCommand', command, function(err)
        if err then vim.notify("Command failed: " .. err.message) end
      end)
    end
  end
end

-- LSP keymaps
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local bufnr = args.buf
    local opts = { buffer = bufnr }

    -- Unset 'formatexpr'
    vim.bo[bufnr].formatexpr = nil
    -- Unset 'omnifunc'
    vim.bo[bufnr].omnifunc = nil

    -- Navigation
    map('n', 'gd', vim.lsp.buf.definition, opts)
    map('n', 'gr', vim.lsp.buf.references, opts)

    -- Code actions mapping
    map('n', '<leader>ca', function()
      local winid = vim.api.nvim_get_current_win()

      -- 1. Get Range (Handles visual selection automatically if active)
      ---@type any
      local params = vim.lsp.util.make_range_params(winid, "utf-8")

      -- 2. Fetch and Transform Diagnostics
      -- Biome relies HEAVILY on these being present in the request
      local line_diagnostics = vim.diagnostic.get(bufnr, { lnum = params.range.start.line })
      local lsp_diagnostics = {}

      for _, d in ipairs(line_diagnostics) do
        table.insert(lsp_diagnostics, {
          range = {
            start = { line = d.lnum, character = d.col },
            ["end"] = { line = d.end_lnum, character = d.end_col },
          },
          severity = d.severity,
          code = d.code,
          source = d.source or "neovim",
          message = d.message,
        })
      end

      params.context = {
        only = { 'source', 'refactor', 'quickfix' }, -- Don't filter, show Biome + vtsls everything
        triggerKind = 1,                             -- Invoked (Manual trigger)
        diagnostics = lsp_diagnostics
      }

      -- 3. Request from all attached servers
      vim.lsp.buf_request_all(bufnr, 'textDocument/codeAction', params, function(responses)
        if not responses or vim.tbl_isempty(responses) then
          vim.notify("No code actions available", vim.log.levels.INFO)
          return
        end

        local all_actions = {}
        for client_id, response in pairs(responses) do
          if response and response.result then
            for _, action in ipairs(response.result) do
              action.client_id = client_id
              table.insert(all_actions, action)
            end
          end
        end

        -- 4. Filter out disabled actions
        local filtered = vim.iter(all_actions)
            :filter(function(item) return not item.disabled end)
            :totable()

        if #filtered == 0 then
          vim.notify("No valid code actions found", vim.log.levels.INFO)
          return
        end

        -- 5. Prepare items for your tmux_popup / fzf
        local display_items = {}
        for i, action in ipairs(filtered) do
          local client = vim.lsp.get_client_by_id(action.client_id)
          local name = client and client.name or "LSP"
          table.insert(display_items, string.format("%d) [%s] %s", i, name, action.title))
        end

        -- 6. UI Selection (Assuming your tmux_popup returns the string)
        local selected_item = tmux_popup(display_items, { fzf = true, prompt = "Code Action > " })
        if not selected_item or selected_item == "" then return end

        local choice_idx = tonumber(selected_item:match("^(%d+)"))
        local action = filtered[choice_idx]
        local client = vim.lsp.get_client_by_id(action.client_id)

        if not client or not action then return end
        apply_action(action, action.client_id, bufnr)
      end)
    end, opts)

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
      format()
    end)
  end,
})
