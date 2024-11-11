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
