return {
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.4",
		dependencies = { "nvim-lua/plenary.nvim" },
		init = function()
			local builtin = require("telescope.builtin")

			vim.keymap.set("n", "<leader>sf", function()
				builtin.find_files()
			end, { desc = "[S]earch [F]iles" })

			vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
			vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })

			vim.keymap.set("n", "gd", builtin.lsp_definitions, { desc = "[G]oto [D]efinition" })
			vim.keymap.set("n", "gI", builtin.lsp_implementations, { desc = "[G]oto [I]mplementation" })
			vim.keymap.set("n", "gr", builtin.lsp_references, { desc = "[G]oto [I]mplementation" })

			vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover Documentation" })

			local telescope_actions = require("telescope.actions")
			require("telescope").setup({
				pickers = {
					live_grep = {
						additional_args = function(_)
							return { "--hidden", "-u" }
						end,
						file_ignore_patterns = {
							".git",
							"build",
							"dist",
							".vercel",
							"node_modules",
							"yarn.lock",
							"pnpm-lock.yaml",
							"package-lock.json",
						},
					},
					find_files = {
						-- `hidden = true` will still show the inside of `.git/` as it's not `.gitignore`d.
						find_command = { "rg", "--files", "-u", "--hidden" },

						file_ignore_patterns = {
							".git",
							"build",
							"dist",
							"node_modules",
							"yarn.lock",
							"pnpm-lock.yaml",
							"package-lock.json",
						},
					},
				},
				defaults = {
					layout_strategy = "horizontal",
					layout_config = {
						horizontal = {
							prompt_position = "bottom",
						},
					},
					mappings = {
						i = {
							["<C-j>"] = telescope_actions.move_selection_next,
							["<C-k>"] = telescope_actions.move_selection_previous,
						},
						n = {
							["<C-j>"] = telescope_actions.move_selection_next,
							["<C-k>"] = telescope_actions.move_selection_previous,
						},
					},
					file_ignore_patterns = {
						".git",
						"build",
						"dist",
						".vercel",
						"yarn.lock",
						"pnpm-lock.yaml",
						"package-lock.json",
					},
				},
				extensions = {
					cmdline = {
						picker = {
							layout_config = {
								width = 50,
								height = 0,
							},
						},
					},
				},
			})
		end,
	},
}
