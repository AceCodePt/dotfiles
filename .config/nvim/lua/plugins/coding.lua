return {
	{
		"sbdchd/neoformat",
		config = function()
			vim.g.neoformat_try_node_exe = 1
		end,
		keys = {
			{ "<leader>fm", ":Neoformat<CR>" },
		},
	},
	{
		"nacro90/numb.nvim",
		opts = {},
	},
	{
		"numToStr/Comment.nvim",
		event = "VeryLazy",
		dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" },
		init = function()
			vim.g.skip_ts_context_commentstring_module = true
		end,
		config = function()
			local comment = require("Comment")
			local comment_string = require("ts_context_commentstring")

			comment.setup({
				pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
			})
			comment_string.setup()
		end,
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
				"<Leader>nf",
				":lua require('neogen').generate()<CR>",
				{ noremap = true, silent = true }
			)
		end,
	},
	{
		"ThePrimeagen/harpoon",
		config = function()
			local harpoon = require("harpoon")
			local harpoon_mark = require("harpoon.mark")
			local harpoon_ui = require("harpoon.ui")

			harpoon.setup({
				menu = {
					width = vim.api.nvim_win_get_width(0) - 4,
				},
			})

			require("telescope").load_extension("harpoon")

			vim.keymap.set("n", "<C-e>", function()
				harpoon_ui.toggle_quick_menu()
			end)
			vim.keymap.set("n", "<C-w>", function()
				harpoon_mark.add_file()
			end)
			vim.keymap.set("n", "<C-a>", function()
				harpoon_ui.nav_file(1)
			end)
			vim.keymap.set("n", "<C-f>", function()
				harpoon_ui.nav_file(2)
			end)
			vim.keymap.set("n", "<C-d>", function()
				harpoon_ui.nav_file(3)
			end)
			vim.keymap.set("n", "<C-s>", function()
				harpoon_ui.nav_file(4)
			end)
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
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
	},
	{
		"kristijanhusak/vim-dadbod-ui",
		dependencies = {
			{ "tpope/vim-dadbod", lazy = true },
			{ "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true }, -- Optional
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
