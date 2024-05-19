return {
	"stevearc/oil.nvim",

	opts = {},
	config = function()
		require("oil").setup({
			experimental_watch_for_changes = true,
			prompt_save_on_select_new_entry = false,
			skip_confirm_for_simple_edits = true,
			delete_to_trash = true,
			view_options = {
				-- Show files and directories that start with "."
				show_hidden = true,
			},
			use_default_keymaps = false,
			keymaps = {
				["g?"] = "actions.show_help",
				["<CR>"] = "actions.select",
				["<C-s>"] = "actions.select_vsplit",
				["<C-h>"] = "actions.select_split",
				["<C-p>"] = "actions.preview",
				["<C-c>"] = "actions.close",
				["<C-l>"] = "actions.refresh",
				["-"] = "actions.parent",
				["_"] = "actions.open_cwd",
				["`"] = "actions.cd",
				["~"] = "actions.tcd",
				["gs"] = "actions.change_sort",
				["gx"] = "actions.open_external",
				["g."] = "actions.toggle_hidden",
				["g\\"] = "actions.toggle_trash",
			},
		})

		vim.keymap.set("n", "<leader>e", "<CMD>Oil<CR>", { desc = "Open parent directory" })
	end,

	-- Optional dependencies
	dependencies = { "nvim-tree/nvim-web-devicons" },
}
