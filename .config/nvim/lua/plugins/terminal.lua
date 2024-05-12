return {
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		config = function()
			local util = require("util.map")
			require("toggleterm").setup({
				start_in_insert = true,
			})
			function _G.set_terminal_keymaps()
				local opts = { buffer = 0, noremap = true }
				util.map("t", "<C-t>", [[<Cmd>ToggleTerm<CR>]], opts)
				util.map("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
				util.map("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
				util.map("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
				util.map("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
				util.map("t", "<C-w>", [[<C-\><C-n><C-w>]], opts)
			end

			-- Set mapping
			vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")
			-- Start by inserting by default
			vim.cmd("autocmd! BufWinEnter,WinEnter term://* startinsert")

			util.map("n", "<C-t>", [[<Cmd> ToggleTerm<CR>]], { silent = false })
		end,
	},
}
