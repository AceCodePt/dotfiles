return {
   "kdheepak/lazygit.nvim",
   init = function()
      vim.keymap.set('n', '<leader>gg', ":LazyGit<cr>", { desc = 'Search [G]it [F]iles' })
   end,
}
