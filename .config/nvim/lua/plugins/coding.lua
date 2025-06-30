return {
	{
		"echasnovski/mini.comment",
		version = "*",
		opts = {
			options = {
				-- Whether to ignore blank lines when commenting
				ignore_blank_line = true,
			},
		},
	},
	{
		"nacro90/numb.nvim",
		opts = {},
	},
	{
		"norcalli/nvim-colorizer.lua",
		config = function()
			require("colorizer").setup()
		end,
	},
	{
		"danymat/neogen",
		config = function()
			local neogen = require("neogen")
			neogen.setup({
				snippet_engine = "luasnip",
				languages = {
					typescript = {
						template = {
							annotation_convention = "jsdoc",
						},
					},
				},
			})
			vim.api.nvim_set_keymap(
				"n",
				"<Leader>ng",
				":lua require('neogen').generate()<CR>",
				{ noremap = true, silent = true }
			)
		end,
	},
	{
		"folke/lazydev.nvim",
		ft = "lua", -- only load on lua files
		opts = {
			library = {
				-- See the configuration section for more details
				-- Load luvit types when the `vim.uv` word is found
				{ path = "luvit-meta/library", words = { "vim%.uv" } },
			},
		},
	},
	{ "Bilal2453/luvit-meta", lazy = true }, -- optional `vim.uv` typings
	{
		"kristijanhusak/vim-dadbod-ui",
		dependencies = {
			{ "tpope/vim-dadbod", lazy = true },
			{ "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql", "mssql" }, lazy = true }, -- Optional
		},
		cmd = {
			"DBUI",
			"DBUIToggle",
			"DBUIAddConnection",
			"DBUIFindBuffer",
		},
		init = function()
			-- Your DBUI configuration
			vim.g.db_ui_use_nerd_fonts = 1
		end,
	},
}
