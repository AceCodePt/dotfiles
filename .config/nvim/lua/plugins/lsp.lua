-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.

local servers_config = {
	tflint = {},
	terraformls = {},
	lua_ls = {},
	html = {},
	cssls = {},
	ts_ls = {},
	eslint = {},
	pyright = {},
	astro = {},
	sqlls = {},
	jsonls = {
		filetypes = { "json", "jsonc" },
		settings = {
			json = {
				-- Schemas https://www.schemastore.org
				schemas = {
					{
						fileMatch = { "package.json" },
						url = "https://json.schemastore.org/package.json",
					},
					{
						fileMatch = { "tsconfig*.json" },
						url = "https://json.schemastore.org/tsconfig.json",
					},
					{
						fileMatch = {
							".prettierrc",
							".prettierrc.json",
							"prettier.config.json",
						},
						url = "https://json.schemastore.org/prettierrc.json",
					},
					{
						fileMatch = { ".eslintrc", ".eslintrc.json" },
						url = "https://json.schemastore.org/eslintrc.json",
					},
					{
						fileMatch = { ".babelrc", ".babelrc.json", "babel.config.json" },
						url = "https://json.schemastore.org/babelrc.json",
					},
					{
						fileMatch = { "now.json", "vercel.json" },
						url = "https://json.schemastore.org/now.json",
					},
				},
			},
		},
	},
}

return {
	{
		"neovim/nvim-lspconfig",
		dependencies = { "hrsh7th/cmp-nvim-lsp" },
		config = function()
			local lspconfig = require("lspconfig")
			local capabilities = require("cmp_nvim_lsp").default_capabilities()
			lspconfig.lua_ls.setup({
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

			for server_name, config in pairs(servers_config) do
				lspconfig[server_name].setup(vim.tbl_deep_extend("force", {
					capabilities = capabilities,
					on_attach = function(_, bufnr)
						local ok, mod = pcall(require, "config.custom-keymaps." .. server_name)
						if ok then
							mod.init(bufnr)
						end
					end,
				}, config))
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
			ensure_installed = vim.tbl_keys(servers_config),
		},
	},
}
