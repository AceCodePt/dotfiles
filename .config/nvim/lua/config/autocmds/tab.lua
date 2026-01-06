vim.api.nvim_create_autocmd("TabEnter", {
  group = vim.api.nvim_create_augroup("TabSpeaker", { clear = true }),
  callback = function()
    local tab_nr = vim.api.nvim_tabpage_get_number(0)
    local message = "Tab " .. tab_nr

    -- We use 'sh -ic' (or 'zsh -ic') to force an interactive shell that loads aliases
    local cmd = { vim.o.shell, "-ic", "speak " .. vim.fn.shellescape(message) }

    vim.fn.jobstart(cmd)
  end,
})
