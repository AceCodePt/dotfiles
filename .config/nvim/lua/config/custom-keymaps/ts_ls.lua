local map = require("util.map").map
local M = {}

function M.init(bufnr)
	local nmap = function(keys, func, desc)
		if desc then
			desc = "LSP: " .. desc
		end

		map("n", keys, func, { buffer = bufnr, desc = desc })
	end
	nmap("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
	nmap("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
	nmap("<leader>rd", ":TermExec cmd='pnpm run dev'<cr>", "pnpm [R]un [D]ev")
	nmap("<leader>rs", ":TermExec cmd='pnpm start'<cr>", "pnpm [R]un [S]tart")

	nmap("<leader>m", function()
		local params = vim.lsp.util.make_range_params()

		params.context = {
			triggerKind = vim.lsp.protocol.CodeActionTriggerKind.Invoked,
			diagnostics = vim.lsp.diagnostic.get_line_diagnostics(),
		}

		local priorities = {
			'Add import from "[^"]+"',
			"Add braces to arrow function",
			"Remove braces from arrow function",
			"Convert named export to default export",
			"Convert default export to named export",
			"Convert to named function",
			"import type",
			"^Use 'type ",
			"^Replace '[^']+' with '[^']+'$",
		}

		vim.lsp.buf_request(bufnr, "textDocument/codeAction", params, function(_, results, _, _)
			local mapped = vim.iter(results)
				:map(function(item)
					local priorities_iter = vim.iter(ipairs(priorities))
					local priority_item = priorities_iter
						:filter(function(_, priority_text)
							return string.find(item.title, priority_text)
						end)
						:totable()[1]

					local priority = priority_item and (100 + #priorities - priority_item[1]) or 0

					return { text = item.title, priority = priority }
				end)
				:totable()

			table.sort(mapped, function(a, b)
				if a.priority == b.priority then
					return #a.text < #b.text
				end
				return a.priority > b.priority
			end)
			-- vim.notify(vim.inspect(mapped))

			vim.lsp.buf.code_action({
				apply = true,
				filter = function(action)
					return action.title == mapped[1].text
				end,
			})
		end)
	end, "Toggle function")
end

return M
