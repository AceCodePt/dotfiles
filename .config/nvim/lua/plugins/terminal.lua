return {
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		config = function()
			local util = require("util.map")
			local Terminal = require("toggleterm.terminal").Terminal
			local char = "t"
			require("toggleterm").setup({
				open_mapping = "<c-" .. char .. ">",
				start_in_insert = true,
				persist_mode = false,
				on_create = function(t)
					t.is_full = false
					local opts = { buffer = t.bufnr, noremap = true }
					util.map("t", "<ESC>", [[<C-\><C-n>]], opts)
					-- To close the currently open terminal
					util.map({ "n", "t" }, "<C-w>", [[<ESC><CMD>q<CR>]], opts)

					-- window movements
					util.map("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
					util.map("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
					util.map("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
					util.map("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
					util.map("t", "<C-f>", function()
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

			util.map("t", "<C-q>", "<CMD>wa<CR><CMD>qa<CR>")
			-- Note: The use of shift keys didn't work on regular terminal
			util.map({ "n", "t" }, "<c-s-" .. char .. ">", function()
				Terminal:new():toggle()
			end)
		end,
	},
}
