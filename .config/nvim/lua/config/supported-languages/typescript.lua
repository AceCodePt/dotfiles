local map = require("util.map").map
local open_and_run_terminal_command = require("util.terminal").open_and_run_terminal_command

local priorities = {
  "Change spelling to '[^']+'",
  'Add import from "[^"]+"',
  'Update import from "[^"]+"',
  "Remove import from '[^']+'",
  "Remove unused declaration for: '[^']+'",
  "Remove unused declarations for: '[^']+'",
  "Remove unused declaration from: '[^']+'",
  "Prefix '[^']+' with an underscore",
  "Infer parameter types from usage",
  "Add braces to arrow function",
  "Remove braces from arrow function",
  "Convert named export to default export",
  "Convert default export to named export",
  "Convert to named function",
  "import type",
  "^Use 'type ",
  "^Replace '[^']+' with '[^']+'$",
}

local filters = {
  "Move to a new file",
}

return {
  fts = { "typescript", "typescriptreact" },
  lsp = {
    name = "ts_ls",
    config = {
      capabilities = {
        workspace = {
          didChangeWatchedFiles = {
            dynamicRegistration = true,
          },
        },
      },
      ---comment
      --- @param client vim.lsp.Client
      --- @param bufnr number
      on_attach = function(client, bufnr)
        local nmap = function(keys, func, desc)
          if desc then
            desc = "LSP: " .. desc
          end

          map("n", keys, func, { buffer = bufnr, desc = desc })
        end
        nmap("<leader>oi", function()
          local params = {
            command = "_typescript.organizeImports",
            arguments = { vim.api.nvim_buf_get_name(0) },
            title = "",
          }

          client:exec_cmd(params)
        end, "[O]rganize [I]mports")

        nmap("<leader>nn", function()
          local current_file_path = vim.fn.expand('%:p')
          local params = ''
          local env_files = vim.fn.glob('.env*', true, true, true)


          if #env_files > 0 then
            params = params .. '--env-file=' .. env_files[1]
          end
          open_and_run_terminal_command("pnpx tsx " .. params .. " " .. current_file_path)
        end, "Node run")

        nmap("<leader>i", function()
          local tbl = vim.lsp.diagnostic.get_line_diagnostics(bufnr)

          local row = vim.iter(tbl)
              :filter(function(item)
                --
                return item["code"] == 2307
              end)
              :pop()

          if row == nil then
            return
          end

          local package = string.gsub(string.match(row["message"], "'.+'"), "'", "")

          open_and_run_terminal_command("ni " .. package)
        end, "Install package")

        nmap("<leader>m", function()
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

          local mapped = vim.iter(results)
              :filter(function(item)
                -- -- Remove filtered items
                return not vim.iter(filters):any(function(filter_item)
                  return string.find(item.title, filter_item) ~= nil
                end)
              end)
              :map(function(item)
                local priorities_iter = vim.iter(ipairs(priorities))
                local priority_item = priorities_iter
                    :filter(function(_, priority_text)
                      return string.find(item.title, priority_text) ~= nil
                    end)
                    :totable()[1]

                local priority = priority_item and (100 + #priorities - priority_item[1]) or 0

                -- Check if item.command exists before modifying it
                if item.command then
                  item.command["priority"] = priority
                  return item.command
                end
                -- Some code actions might be structured differently
                return item
              end)
              :filter(function(item) -- Ensure we only have items with a command
                return item.command ~= nil
              end)
              :totable()

          if vim.tbl_isempty(mapped) then
            vim.notify("No actionable items found after filtering.", vim.log.levels.INFO)
            return
          end

          table.sort(mapped, function(a, b)
            if a.priority == b.priority then
              return #a.title < #b.title
            end
            return a.priority > b.priority
          end)

          local selected_command = mapped[1]

          if selected_command then
            if client then
              client:exec_cmd(selected_command, { bufnr = bufnr })
            end
          end
        end, "[M]agic Fix")
      end
    }
  },
  treesitter = {
    "typescript",
    "tsx"
  },
  formatters = { "prettierd", "prettier" }
}
