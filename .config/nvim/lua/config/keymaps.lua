local map = require("util.map").map
local actions = require("util.actions")
local create_nvim_keybind_callback = require("util.expression").create_nvim_keybind_callback
local converter = require('util.case_converter')

vim.g.mapleader = " "
vim.g.maplocalleader = " "

---@param motion_char string
local function move_and_center(motion_char)
  return function()
    local count = vim.v.count
    local keys_to_feed

    if motion_char:find("<", 1, true) then
      -- For special keys like <C-u>, <C-d>, etc.
      -- If a count is present, prepend it.
      if count > 0 then
        keys_to_feed = count .. motion_char
      else
        keys_to_feed = motion_char
      end
    else
      -- For single characters like 'j' or 'k'
      if count > 0 then
        keys_to_feed = count .. motion_char
      else
        -- If no count, and it's 'j' or 'k', we can consider 'gj'/'gk'
        -- or just the literal 'j'/'k'. Your original logic for 'g' prefix
        -- seems to indicate a desire for line-based movement rather than display-line.
        -- If you want 'gj'/'gk' for no-count 'j'/'k', use:
        -- keys_to_feed = "g" .. motion_char
        -- Otherwise, for standard 'j'/'k' without count, it's just the motion_char:
        keys_to_feed = motion_char
      end
    end

    -- Feed the generated key sequence.
    -- It's crucial to use vim.api.nvim_replace_termcodes for ALL `keys_to_feed`
    -- as it handles both "<C-u>" and "j" (and counts like "5j") correctly.
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys_to_feed, true, true, true), "nx", true)

    -- Now, explicitly call the built-in "zz" command to center the view.
    vim.cmd("normal! zz")
  end
end

map({ "n", "x" }, "j", move_and_center("j"))
map({ "n", "x" }, "k", move_and_center("k"))
map({ "n" }, "<C-u>", move_and_center("<C-u>"))
map({ "n" }, "<C-d>", move_and_center("<C-d>"))
map({ "n" }, "<C-b>", move_and_center("<C-b>"))
map({ "n" }, "<C-f>", move_and_center("<C-f>"))
map({ "n" }, "<M-h>", move_and_center("<C-o>"), { desc = "Jump back" })
map({ "n" }, "<M-l>", move_and_center("<C-i>"), { desc = "Jump forward" })

-- Better J behavior
map("n", "J", "mzJ`z", { desc = "Join lines and keep cursor position" })

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

map({ 'n', 'v' }, '<leader>v', function()
  if vim.fn.mode() == 'n' then
    vim.cmd('normal! viw')
  end
  local selection_text
  local current_mode = vim.fn.mode()
  local start_pos = vim.fn.getpos("v")
  local end_pos = vim.fn.getpos(".")

  if current_mode == 'V' and start_pos[2] == end_pos[2] then
    selection_text = vim.api.nvim_get_current_line()
  else
    local selection_lines = vim.fn.getregion(start_pos, end_pos, { type = current_mode })
    if not selection_lines or #selection_lines == 0 then
      return
    end
    selection_text = table.concat(selection_lines, '\n')
  end

  if selection_text == '' then
    return
  end

  local escaped_text = vim.fn.escape(selection_text, [[\/.*^$[]~\]])
  local final_pattern = escaped_text:gsub('\n', '\\n')
  local cmd = "%s/" .. final_pattern .. "//g"

  vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), "n")
  vim.fn.feedkeys(":" .. cmd, "t")
  vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Left><Left>', true, false, true), "t")
end, {
  desc = "Substitute selected text"
})


local function show_nvim_messages()
  vim.api.nvim_command('enew')
  vim.api.nvim_set_option_value('buftype', 'nofile', { scope = 'local' })
  vim.api.nvim_set_option_value('bufhidden', 'wipe', { scope = 'local' })

  vim.cmd('file Messages')

  local result = vim.api.nvim_exec2('messages', { output = true })
  local all_messages_string = result.output or ""

  local messages_table = vim.split(all_messages_string, '\n', { plain = true, trimempty = true })

  vim.api.nvim_buf_set_lines(0, 0, -1, false, messages_table)
  vim.cmd('setlocal nomodifiable')
  vim.cmd('setlocal noswapfile')

  vim.api.nvim_feedkeys('G', 't', false)

  map('n', '<esc>', "<C-o>", {
    buffer = vim.api.nvim_get_current_buf(),
    desc = "Quit messages buffer"
  })
  map({ 'n', "v" }, 'q', "<C-o>", {
    buffer = vim.api.nvim_get_current_buf(),
    desc = "Quit messages buffer"
  })
end

map('n', '<leader>sm', show_nvim_messages, {
  desc = "Show Neovim Messages"
})
