local map = require("util.map").map
local actions = require("util.actions")
local create_nvim_keybind_callback = require("util.expression").create_nvim_keybind_callback
local converter = require('util.case_converter')

vim.g.mapleader = " "
vim.g.maplocalleader = " "

local function move_and_center(motion_char)
  local count = vim.v.count
  local keys_to_feed -- This will hold the key sequence to send

  if count > 0 then
    -- If a count is given, form the string like "5j" or "3k"
    keys_to_feed = count .. motion_char
  else
    -- If no count, form the string like "gj" or "gk"
    keys_to_feed = "g" .. motion_char
  end

  -- Feed the generated key sequence (e.g., "gj" or "5j") to Neovim.
  -- "nx": Apply in Normal and Visual modes.
  -- true: Means these keys should NOT be remapped by other mappings.
  --       This ensures 'j', 'k', 'gj', 'gk' perform their literal motions.
  vim.api.nvim_feedkeys(keys_to_feed, "nx", true)

  -- Now, explicitly call the built-in "zz" command to center the view.
  -- "normal! zz" is used to ensure the original 'zz' behavior,
  -- bypassing any potential user remappings of 'zz'.
  vim.cmd("normal! zz")
end

map({ "n", "x" }, "j", function()
  move_and_center("j")
end, { noremap = true, silent = true })

map({ "n", "x" }, "k", function()
  move_and_center("k")
end, { noremap = true, silent = true })

-- Better J behavior
map("n", "J", "mzJ`z", { desc = "Join lines and keep cursor position" })


map('n', '<M-w>', ':tabclose<CR>', { desc = 'Close current tab' })
map('n', '<M-t>', ':tabnew | term<CR>', { desc = 'Create new tab with terminal' })
map('n', '<M-j>', ':tabprevious<CR>', { desc = 'Go to previous tab' })
map('n', '<M-k>', ':tabnext<CR>', { desc = 'Go to next tab' })
map('n', '<M-J>', ':-tabmove<CR>', { desc = 'Move to previous tab' })
map('n', '<M-K>', ':+tabmove<CR>', { desc = 'Go to next tab' })

-- Mimic harpoon style
map('n', '<M-a>', ':1tabnext<CR>', { desc = 'Go to first tab' })
map('n', '<M-s>', ':2tabnext<CR>', { desc = 'Go to second tab' })
map('n', '<M-d>', ':3tabnext<CR>', { desc = 'Go to third tab' })
map('n', '<M-f>', ':4tabnext<CR>', { desc = 'Go to fourth tab' })


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


map({ "n" }, "<M-h>", "<C-o>", { desc = "Jump back" })
map({ "n" }, "<M-l>", "<C-i>", { desc = "Jump forward" })
map({ "v", "n" }, "H", "^")
map({ "n" }, "cH", "c^")
map({ "n" }, "dH", "d^")

map({ "v", "n" }, "L", "$")
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

-- Trick from the primagen
map("n", "<leader>v", [[:%s/\<<C-r><C-w>\>//gI<Left><Left><Left>]])

-- Jumping is slightly better
map("n", "gg", function()
  vim.cmd("keepjumps normal! ggzz")
end, { desc = "Go to first line without adding to jumplist" })

map("n", "G", function()
  vim.cmd("keepjumps normal! Gzz")
end, { desc = "Go to last line without adding to jumplist" })

map("n", "{", function()
  vim.cmd("keepjumps normal! {zz")
end, { desc = "Go to next blank line without adding to jumplist" })

map("n", "}", function()
  vim.cmd("keepjumps normal! }zz")
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
    fp = "%:p",   -- Absolute Path
    ffn = "%:t",  -- Full Filename (Tail)
    frp = "%:h",  -- Root Path (Head)
    fn = "%:t:r", -- Filename without extension
  }) do
    map({ 'n', 'v', 'x' }, '<leader>' .. prefix .. keys, create_nvim_keybind_callback(fn, expr))
  end
end

map('t', '<Esc>', '<C-\\><C-N>', { desc = 'Escape terminal mode' })
