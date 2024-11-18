local M = require("util.map")
local map = M.map

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- better up/down
map({ "n", "x" }, "j", function()
	return vim.v.count > 0 and "j" or "gj"
end, { expr = true })
map({ "n", "x" }, "k", function()
	return vim.v.count > 0 and "k" or "gk"
end, { expr = true })

map("n", "<C-u>", "<C-u>zz")
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-b>", "<C-b>zz")
map("n", "<C-f>", "<C-f>zz")

map({ "n", "v" }, "y", '"+y')
map({ "n", "v" }, "Y", '"+y$')

-- Capital P doesn't yank the line again
map({ "n" }, "p", '"+p')
map({ "v" }, "p", '"+P')
map({ "n", "v" }, "P", '"+P')

map({ "n", "v" }, "d", '"+d')
map({ "n", "v" }, "D", '"+D')

-- Disable copying for X
map({ "n", "v" }, "x", '"_x')
map({ "n", "v" }, "X", '"_X')

-- Diagnostic for convnience
map({ "n" }, "gp", vim.diagnostic.goto_prev)
map({ "n" }, "gn", vim.diagnostic.goto_next)

map({ "n", "v" }, "H", "^")
map({ "n" }, "cH", "c^")
map({ "n" }, "dH", "d^")

map({ "n", "v" }, "L", "$")
map({ "n" }, "cL", "c$")
map({ "n" }, "dL", "d$")

-- Center search results
map("n", "n", "nzz")
map("n", "N", "Nzz")

-- Better indentation
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Move selected line / block of text in visual mode
map("n", "J", "gJ")
map("n", "K", "gK")
map("v", "J", ":move '>+1<CR>gv-gv")
map("v", "K", ":move '<-2<CR>gv-gv")

-- Trick from the primagen
map("n", "<leader>v", [[:%s/\<<C-r><C-w>\>//gI<Left><Left><Left>]])

vim.keymap.set({ "n", "t" }, "<C-s-o>", "gx", { desc = "OpenUrl Undercurword" })
