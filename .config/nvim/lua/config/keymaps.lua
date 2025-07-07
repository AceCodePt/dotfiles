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

-- Better J behavior
map("n", "J", "mzJ`z", { desc = "Join lines and keep cursor position" })


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


map({ "n" }, "H", "<c-o>")
map({ "v" }, "H", "^")
map({ "n" }, "cH", "c^")
map({ "n" }, "dH", "d^")

map({ "n" }, "L", "<c-i>")
map({ "v" }, "L", "$")
map({ "n" }, "cL", "c$")
map({ "n" }, "dL", "d$")

-- Center search results
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- Better indentation
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Move selected line / block of text in visual mode
map("v", "J", ":move '>+1<CR>gv-gv")
map("v", "K", ":move '<-2<CR>gv-gv")

-- Buffer navigation
map("n", "<leader>bn", ":bnext<CR>", { desc = "Next buffer" })
map("n", "<leader>bp", ":bprevious<CR>", { desc = "Previous buffer" })

-- Trick from the primagen
map("n", "<leader>v", [[:%s/\<<C-r><C-w>\>//gI<Left><Left><Left>]])

-- Jumping is slightly better
map("n", "gg", function()
  vim.cmd("keepjumps normal! gg")
end, { desc = "Go to first line without adding to jumplist" })

map("n", "G", function()
  vim.cmd("keepjumps normal! G")
end, { desc = "Go to last line without adding to jumplist" })

map("n", "{", function()
  vim.cmd("keepjumps normal! {")
end, { desc = "Go to next blank line without adding to jumplist" })

map("n", "}", function()
  vim.cmd("keepjumps normal! }")
end, { desc = "Go to previous blank line without adding to jumplist" })


-- Quick config editing
map("n", "<leader>rc", ":e ~/.config/nvim/init.lua<CR>", { desc = "Edit config" })

-- Copy Full File-Path
vim.keymap.set("n", "<leader>pa", function()
  local path = vim.fn.expand("%:p")
  vim.fn.setreg("+", path)
  print("file:", path)
end)

-- Create a keymap for visual mode for easier access.
-- Usage: Select text, then press <leader>c
-- The '<,'> part automatically passes the visual selection range to the command.
map("v", "<leader>cc", ":'<,'>CamelCase<CR>", {
  desc = "Convert selection to camelCase",
})
