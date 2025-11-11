local map = require("util.map").map
local open_and_run_terminal_command = require("util.terminal").open_and_run_terminal_command

map('t', '<Esc>',
  function()
    if vim.g.zsh_keymap == 'vicmd' then
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-\\><C-N>", true, true, true), 'n', false)
    else
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<ESC>", true, true, true), 'n', false)
    end
  end
  , { desc = 'Escape terminal mode' })

local augroup = vim.api.nvim_create_augroup("UserTerminal", { clear = true })

vim.api.nvim_create_autocmd('BufEnter', {
  pattern = '/tmp/zsh*.zsh',
  desc = 'Create special keymap for Zsh command editing',
  callback = function(args)
    map('n', '<Esc>', function()
      local edit_buf = vim.api.nvim_get_current_buf()
      vim.cmd.write()
      vim.cmd('buffer #')
      vim.api.nvim_buf_delete(edit_buf, { force = false })
    end, {
      buffer = args.buf,
      desc = 'Close Zsh edit buffer'
    })
  end,
})

-- This is a better coping mechnizem for copy
vim.api.nvim_create_autocmd({ "TextYankPost" }, {
  group = augroup,
  pattern = "term://*",
  callback = function()
    local width = vim.api.nvim_win_get_width(0) - 2
    local offset = vim.api.nvim_win_get_cursor(0)[2]
    local yanked_text = vim.fn.getreg("+")
    local new_str = ""
    local count = 1
    while true do
      local next_index = string.find(yanked_text, "\n", count)
      if next_index == nil then
        new_str = new_str .. string.sub(yanked_text, count, string.len(yanked_text))
        break
      end
      if next_index - count + offset >= width then
        new_str = new_str .. string.sub(yanked_text, count, next_index - 1)
      else
        new_str = new_str .. string.sub(yanked_text, count, next_index)
      end
      count = next_index + 1
      offset = 0
    end
    vim.fn.setreg("+", new_str)
  end,
})

-- Made vim enter with some sick npm commands
vim.api.nvim_create_autocmd("VimEnter", {
  group = augroup,
  callback = function()
    local res = vim.fs.find("package.json", { limit = 1, type = "file" })
    if res == nil or res[1] == nil then
      return
    end

    map('n', '<leader>nd', function()
      open_and_run_terminal_command('nr dev', { location = "start", unfocus = true })
    end, { desc = "[N]PM [D]ev" })

    map('n', '<leader>ns', function()
      open_and_run_terminal_command('nr start')
    end, { desc = "[N]PM [S]tart" })

    map('n', '<leader>ni', function()
      open_and_run_terminal_command('ni', { exit_on_success = true })
    end, { desc = "[N]PM [I]nstall" })
  end,
})

vim.api.nvim_create_autocmd({ "TermEnter", "TermLeave", "TabLeave" }, {
  group = augroup,
  pattern = "term://*",
  desc = "Sync tab CWD when entering or leaving a terminal",
  callback = function()
    if vim.fn.has("win32") == 1 or vim.fn.has("bsd") == 1 then
      return
    end

    local job_id = vim.b.terminal_job_id
    if not job_id then return end

    local jobwait = vim.fn.jobwait({ job_id }, 0)
    local running = jobwait[1] == -1
    if not running then
      return
    end

    local pid = vim.fn.jobpid(job_id)
    if not pid or pid <= 0 then
      return
    end

    local proc_path = string.format("/proc/%d/cwd", pid)

    local ok, term_dir = pcall(vim.loop.fs_readlink, proc_path)

    if ok and term_dir and term_dir ~= vim.fn.getcwd(-1) then
      vim.cmd.tcd({ args = { term_dir } })
    end
  end,
})
