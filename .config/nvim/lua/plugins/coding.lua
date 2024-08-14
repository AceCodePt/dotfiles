return {
	{
		"tpope/vim-sleuth",
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
				"<Leader>nf",
				":lua require('neogen').generate({ type = 'func' })<CR>",
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
}
