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
		textobjects = {
			select = {
				enable = true,
				lookahead = true,
				keymaps = {
					["af"] = "@function.outer",
					["if"] = "@function.inner",
					["ac"] = "@class.outer",
					["ic"] = "@class.inner",
				},
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
