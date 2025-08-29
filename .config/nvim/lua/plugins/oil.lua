local map = require("util.map").map
vim.pack.add({ { src = "https://github.com/stevearc/oil.nvim" } })

local oil = require("oil")
map("n", "<leader>e", "<CMD>Oil --float<CR>", { desc = "Open Oil" })
oil.setup({
  experimental_watch_for_changes = true,
  prompt_save_on_select_new_entry = false,
  skip_confirm_for_simple_edits = true,
  delete_to_trash = true,
  view_options = {
    -- Show files and directories that start with "."
    show_hidden = true,
  },
  use_default_keymaps = false,
  keymaps = {
    ["g?"] = "actions.show_help",
    ["<CR>"] = "actions.select",
    ["<C-s>"] = "actions.select_vsplit",
    ["<C-h>"] = "actions.select_split",
    ["<C-p>"] = "actions.preview",
    ["<C-l>"] = "actions.refresh",
    ["<leader>e"] = "actions.close",
    ["<Esc>"] = "actions.close",
    ["-"] = "actions.parent",
    ["_"] = "actions.open_cwd",
    ["`"] = "actions.cd",
    ["~"] = "actions.tcd",
    ["gs"] = "actions.change_sort",
    ["gx"] = "actions.open_external",
    ["g."] = "actions.toggle_hidden",
    ["g\\"] = "actions.toggle_trash",
  },
})

local group = vim.api.nvim_create_augroup("remove_buffer_on_file_delete", { clear = true })
vim.api.nvim_create_autocmd("User", {
  pattern = "OilActionsPost",
  group = group,
  callback = function(e)
    if e.data.actions == nil then
      return
    end
    for _, action in ipairs(e.data.actions) do
      if action.entry_type == "file" and action.type == "delete" then
        local file = action.url:sub(7)
        local bufnr = vim.fn.bufnr(file)

        if bufnr >= 0 then
          vim.api.nvim_buf_delete(bufnr, { force = true })
        end
      end
    end
  end
})
