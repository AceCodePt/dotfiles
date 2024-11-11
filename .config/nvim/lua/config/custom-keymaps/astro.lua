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
		vim.lsp.buf.code_action({
			apply = true,
			filter = function(action)
				if
					string.find(action.title, "Add braces to arrow function")
					or string.find(action.title, "Remove braces from arrow function")
					or string.find(action.title, "Convert named export to default export")
					or string.find(action.title, "Convert default export to named export")
				then
					return true
				else
					return false
				end
			end,
		})
	end, "Toggle function")
end

return M
