return {
	{
		"windwp/nvim-ts-autotag",
		config = function()
			require("nvim-ts-autotag").setup()
		end,
	},
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = function()
			require("nvim-autopairs").setup({
				check_ts = true,

				disable_filetype = { "TelescopePrompt", "vim" },
			})
		end,
		-- use opts = {} for passing setup options
		-- this is equivalent to setup({}) function
	},
	{
		"kylechui/nvim-surround",
		version = "*",
		event = "VeryLazy",
		config = function()
			require("nvim-surround").setup({
				keymaps = {
					normal = "gs",
					normal_cur = "gss",
				},
			})
		end,
	},
}
