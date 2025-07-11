local map = require("util.map").map
local actions = require("util.actions")
local create_nvim_keybind_callback = require("util.expression").create_nvim_keybind_callback
local converter = require('util.case_converter')

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
map("n", "<leader>pa", function()
  local path = vim.fn.expand("%:p")
  vim.fn.setreg("+", path)
  print("file:", path)
end)

map('v', '<leader>ccc', converter.convert_selection_to_camel, { desc = 'Convert to camelCase' })
map('v', '<leader>ccp', converter.convert_selection_to_pascal, { desc = 'Convert to PascalCase' })
map('v', '<leader>ccs', converter.convert_selection_to_snake, { desc = 'Convert to snake_case' })
map('v', '<leader>cck', converter.convert_selection_to_kebab,
  { desc = 'Convert to kebab-case' })

for prefix, fn in pairs({ y = actions.yank, p = actions.paste }) do
  for keys, expr in pairs({
    fap = "%:p",  -- Absolute Path
    ffn = "%:t",  -- Full Filename (Tail)
    frp = "%:h",  -- Root Path (Head)
    fn = "%:t:r", -- Filename without extension
  }) do
    map({ 'n', 'v', 'x' }, '<leader>' .. prefix .. keys, create_nvim_keybind_callback(fn, expr))
  end
end
