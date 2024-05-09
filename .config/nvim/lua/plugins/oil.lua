return {
   'stevearc/oil.nvim',

   opts = {},
   config = function()
      require("oil").setup({

         prompt_save_on_select_new_entry = false,
         skip_confirm_for_simple_edits = true,
         delete_to_trash = true,
         view_options = {
            -- Show files and directories that start with "."
            show_hidden = true,
         }
      })

      vim.keymap.set("n", "<leader>e", "<CMD>Oil<CR>", { desc = "Open parent directory" })
   end,

   -- Optional dependencies
   dependencies = { "nvim-tree/nvim-web-devicons" },
}
