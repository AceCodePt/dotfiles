return {
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		config = function()
			local util = require("util.map")
			local Terminal = require("toggleterm.terminal").Terminal
			require("toggleterm").setup({
				start_in_insert = true,
				persist_mode = false,
				on_create = function(t)
					local opts = { buffer = t.bufnr, noremap = true }
					util.map("t", "<ESC>", [[<C-\><C-n>]], opts)
					util.map("t", "<C-t>", function()
						vim.cmd([[ToggleTerm]])
					end, opts)
					util.map("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
					util.map("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
					util.map("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
					util.map("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
				end,
			})

			util.map("t", "<C-q>", "<CMD>wa<CR><CMD>qa<CR>")
			-- Note: this is working on alacrity for me
			util.map({ "n", "t" }, "<C-s-t>", function()
				Terminal:new():toggle()
			end)
			util.map({ "n", "t" }, "<C-t>", [[<Cmd> ToggleTerm<CR>]])
		end,
	},
}
