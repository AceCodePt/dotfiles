return {
   {
      "nvim-telescope/telescope.nvim",
      tag = "0.1.4",
      dependencies = { "nvim-lua/plenary.nvim" },
      init = function()
         local builtin = require("telescope.builtin")

         vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
         vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
         vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })


         vim.keymap.set('n','gd', builtin.lsp_definitions, {desc = '[G]oto [D]efinition' })
         vim.keymap.set('n','gI', builtin.lsp_implementations,{desc = '[G]oto [I]mplementation'})
         vim.keymap.set('n','gr', builtin.lsp_references,{desc = '[G]oto [I]mplementation'})

         vim.keymap.set('n', 'K', vim.lsp.buf.hover, {desc ='Hover Documentation'})

         local telescope_actions = require('telescope.actions')
         require('telescope').setup {
           defaults = {
             layout_strategy = "horizontal",
             layout_config = {
               horizontal = {
                 prompt_position = "bottom",
               },
             },
             mappings = {
               i = {
                 ["<C-j>"] = telescope_actions.move_selection_next,
                 ["<C-k>"] = telescope_actions.move_selection_previous,
               },
               n = {
                 ["<C-j>"] = telescope_actions.move_selection_next,
                 ["<C-k>"] = telescope_actions.move_selection_previous,
               },
             },
           },
           extensions = {
             cmdline = {
               picker = {
                 layout_config = {
                   width  = 50,
                   height = 0,
                 }
               },
             },
           }
         }
      end,
   },
}
