return {
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		config = function()
			local map = require("util.map").map
			local Terminal = require("toggleterm.terminal").Terminal
			local char = "t"
			require("toggleterm").setup({
				open_mapping = "<c-" .. char .. ">",
				start_in_insert = false,
				persist_mode = false,
				on_create = function(t)
					t.is_full = false
					local opts = { buffer = t.bufnr }
					map("t", "<ESC>", [[<C-\><C-n>]], opts)
					-- To close the currently open terminal
					map({ "n", "t" }, "<C-w>", [[<ESC><CMD>q<CR>]], opts)

					-- window movements
					map("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
					map("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
					map("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
					map("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
					map("t", "<C-f>", function()
						if t.is_full then
							vim.cmd("resize " .. 12)
							t.is_full = false
						else
							vim.cmd("resize " .. 24)
							t.is_full = true
						end
					end, opts)
				end,
			})

			-- Note: The use of shift keys didn't work on regular terminal
			map({ "n", "t" }, "<c-s-" .. char .. ">", function()
				Terminal:new():toggle()
			end)
		end,
	},
}
