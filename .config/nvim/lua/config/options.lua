-- Set highlight on search
vim.o.hlsearch = false

-- Disable mouse stuff
vim.opt.mouse = ""

-- Make line numbers default
vim.wo.number = true

-- Enable relative line numbere
vim.wo.rnu = true
vim.opt.scrolloff = 10

-- Sync clipboard between OS and Neovim.
vim.o.clipboard = "unnamedplus"

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = "yes"

-- Set tabs
vim.o.tabstop = 2
vim.o.expandtab = true
vim.o.shiftwidth = 2

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = "menuone,noselect"

-- Have colors (I'm using ZSH)
vim.o.termguicolors = true

-- Stop with the swap file!
vim.o.swapfile = false
vim.o.cursorline = true
vim.opt.guicursor = "n:Cursor,v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20"

vim.api.nvim_create_autocmd({ "VimEnter", "ColorScheme" }, {
	group = vim.api.nvim_create_augroup("InvisibleCursor", { clear = true }),
	callback = function()
		vim.api.nvim_set_hl(0, "Cursor", { reverse = true, blend = 100 })
	end,
	once = true, -- Ensures the callback runs only once for each event
})
