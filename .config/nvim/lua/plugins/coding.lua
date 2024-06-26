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
}
