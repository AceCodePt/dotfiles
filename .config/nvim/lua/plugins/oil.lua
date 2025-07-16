return {
  {
    "stevearc/oil.nvim",
    keys = {
      {
        "<leader>e",
        "<CMD>Oil --float<CR>",
        desc = "Open parent directory",
      },
    },
    opts = {
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
        ["q"] = "actions.close",
        ["-"] = "actions.parent",
        ["_"] = "actions.open_cwd",
        ["`"] = "actions.cd",
        ["~"] = "actions.tcd",
        ["gs"] = "actions.change_sort",
        ["gx"] = "actions.open_external",
        ["g."] = "actions.toggle_hidden",
        ["g\\"] = "actions.toggle_trash",
      },
    },

    -- Optional dependencies
    dependencies = {
      { "nvim-treesitter/nvim-treesitter" },
      { "nvim-tree/nvim-web-devicons",    opts = {} },
    },
  },
}
