-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.

local languages = {
	"tflint",
	"terraformls",
	"lua_ls",
	"clangd",
	"html",
	"cssls",
	"ts_ls",
	"eslint",
	"pyright",
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

			for _, language in pairs(languages) do
				require("lspconfig")[language].setup({
					capabilities = capabilities,
					on_attach = function(_, bufnr)
						local ok, mod = pcall(require, "config.custom-keymaps." .. language)
						if ok then
							mod.init(bufnr)
						end
					end,
				})
			end

			vim.lsp.handlers["textDocument/publishDiagnostics"] =
				vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
					virtual_text = true,
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
