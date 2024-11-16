local config = function()
	require("nvim-treesitter.configs").setup({
		auto_install = false,

		sync_install = true,
		ignore_install = {},
		modules = {},

		ensure_installed = {
			"c",
			"cpp",
			"python",
			"lua",
			"vim",
			"javascript",
			"typescript",
			"astro",
			"json",
			"html",
			"css",
			"sql",
			"comment",
			"vimdoc",
			"tsx",
		},
		highlight = { enable = true },
		indent = { enable = false },
		autotag = { enable = false },
		incremental_selection = {
			enable = true,
			keymaps = {
				init_selection = "<leader>ti",
				scope_incremental = "<leader>ts",
				node_incremental = "<leader>ti",
				node_decremental = "<leader>td",
			},
		},
	})
end
return {
	{
		"nvim-treesitter/nvim-treesitter",
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
		},
		build = ":TSUpdate",
		config = config,
	},
}
