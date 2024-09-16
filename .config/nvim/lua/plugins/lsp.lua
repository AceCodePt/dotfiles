-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.

local languages = {
	"lua_ls",
	"clangd",
	"html",
	"cssls",
	"ts_ls",
	"eslint",
	"tailwindcss",
	"pyright",
	"gopls",
	"astro",
}

return {
	{
		"neovim/nvim-lspconfig",
		dependencies = { "hrsh7th/cmp-nvim-lsp" },
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()
			require("lspconfig").lua_ls.setup({
				on_init = function(client)
					local path = client.workspace_folders[1].name
					if
						not vim.loop.fs_stat(path .. "/.luarc.json") and not vim.loop.fs_stat(path .. "/.luarc.jsonc")
					then
						client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
							runtime = {
								-- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
								version = "LuaJIT",
							},
							workspace = {
								library = { vim.env.VIMRUNTIME },
							},
						})

						client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
					end
					return true
				end,
			})

			local on_attach = function(_, bufnr)
				-- In this case, we create a function that lets us more easily define mappings specific
				-- for LSP related items. It sets the mode, buffer and description for us each time.
				local nmap = function(keys, func, desc)
					if desc then
						desc = "LSP: " .. desc
					end

					vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
				end

				nmap("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
				nmap("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")

				nmap("<leader>m", function()
					vim.lsp.buf.code_action({
						apply = true,
						filter = function(action)
							if
								string.find(action.title, "Add braces to arrow function")
								or string.find(action.title, "Remove braces from arrow function")
								or string.find(action.title, "Convert named export to default export")
								or string.find(action.title, "Convert default export to namef export")
							then
								return true
							else
								return false
							end
						end,
					})
				end, "Toggle function")
			end

			require("lspconfig").tailwindcss.setup({
				on_attach = function()
					require("tailwindcss-colors").buf_attach(0)
				end,
			})

			for _, language in pairs(languages) do
				require("lspconfig")[language].setup({
					capabilities = capabilities,
					on_attach = on_attach,
				})
			end

			vim.lsp.handlers["textDocument/publishDiagnostics"] =
				vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
					virtual_text = false,
				})
		end,
	},
	{
		"williamboman/mason.nvim",
		opts = {},
	},
	{
		"williamboman/mason-lspconfig.nvim",
		opts = {
			ensure_installed = languages,
		},
	},
}
