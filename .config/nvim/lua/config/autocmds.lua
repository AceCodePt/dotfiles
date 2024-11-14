local map = require("util.map").map

-- only highlight when searching
vim.api.nvim_create_autocmd("CmdlineEnter", {
	callback = function()
		local cmd = vim.v.event.cmdtype
		if cmd == "/" or cmd == "?" then
			vim.opt.hlsearch = true
		end
	end,
})
vim.api.nvim_create_autocmd("CmdlineLeave", {
	callback = function()
		local cmd = vim.v.event.cmdtype
		if cmd == "/" or cmd == "?" then
			vim.opt.hlsearch = false
		end
	end,
})

-- Disable auto comment
vim.api.nvim_create_autocmd("BufEnter", {
	callback = function()
		vim.opt.formatoptions = { c = false, r = false, o = false }
	end,
})

-- Highlight when yanking
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank({ timeout = 80 })
	end,
})

vim.api.nvim_create_autocmd({ "TextYankPost" }, {
	pattern = "term://*",
	callback = function()
		local width = vim.api.nvim_win_get_width(0) - 2
		local offset = vim.api.nvim_win_get_cursor(0)[2]
		local yanked_text = vim.fn.getreg("+")
		local new_str = ""
		local count = 1
		while true do
			local next_index = string.find(yanked_text, "\n", count)
			if next_index == nil then
				new_str = new_str .. string.sub(yanked_text, count, string.len(yanked_text))
				break
			end
			if next_index - count + offset >= width then
				new_str = new_str .. string.sub(yanked_text, count, next_index - 1)
			else
				new_str = new_str .. string.sub(yanked_text, count, next_index)
			end
			count = next_index + 1
			offset = 0
		end
		vim.fn.setreg("+", new_str)
	end,
})
