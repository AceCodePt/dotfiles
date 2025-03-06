return {
	{
		"yetone/avante.nvim",
		event = "VeryLazy",
		lazy = false,
		version = false, -- Set this to "*" to always pull the latest release version, or set it to false to update to the latest code changes.
		opts = {
			provider = "claude", -- Recommend using Claude
			auto_suggestions_provider = "claude",
			claude = {
				endpoint = "https://api.anthropic.com",
				model = "claude-3-5-sonnet-20241022",
				temperature = 0,
				max_tokens = 4096,
			},
			suggestion = {
				debounce = 1200,
				throttle = 1200,
			},
		},
		build = "make",
		dependencies = {
			"stevearc/dressing.nvim",
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			--- The below dependencies are optional,
			"echasnovski/mini.pick", -- for file_selector provider mini.pick
			"nvim-telescope/telescope.nvim", -- for file_selector provider telescope
			"hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
			"ibhagwan/fzf-lua", -- for file_selector provider fzf
			"nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
			"zbirenbaum/copilot.lua", -- for providers='copilot'
			{
				-- support for image pasting
				"HakonHarnes/img-clip.nvim",
				event = "VeryLazy",
				opts = {
					-- recommended settings
					default = {
						embed_image_as_base64 = false,
						prompt_for_file_name = false,
						drag_and_drop = {
							insert_mode = true,
						},
						-- required for Windows users
						use_absolute_path = true,
					},
				},
			},
			{
				-- Make sure to set this up properly if you have lazy=true
				"MeanderingProgrammer/render-markdown.nvim",
				opts = {
					file_types = { "markdown", "Avante" },
				},
				ft = { "markdown", "Avante" },
			},
		},
	},
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
