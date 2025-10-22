local map = require("util.map").map
local fzf_tmux = require("util.fzf_tmux")

local config = {
  search_dirs = vim.fn.shellescape(vim.fn.expand("$HOME/companies")) ..
      " " .. vim.fn.shellescape(vim.fn.expand("$HOME/stuff")) ..
      " " .. vim.fn.shellescape(vim.fn.expand("$HOME/dotfiles")),


  -- Simple filenames. Dots will be escaped automatically.
  file_markers = {
    "package.json",
    "go.mod",
    "Cargo.toml",
    "pyproject.toml",
    "setup.py",
    "requirements.txt",
    "Pipfile",
    ".venv",
    "Makefile",
    "Dockerfile",
  },

  -- Markers that are already valid regular expressions.
  regex_markers = {
    ".*\\.git", -- Matches any folder ending in .git
  },
}

-- Corrected session name derivation from the previous analysis
local function derive_session_name(project_path)
  local parent_dir = vim.fn.fnamemodify(project_path, ":h")
  local project_name = vim.fn.fnamemodify(project_path, ":t")

  local bare_repo_path = vim.fn.glob(parent_dir .. "/*.git", true, true)

  local raw_name
  if #bare_repo_path > 0 then
    local parent_name = vim.fn.fnamemodify(parent_dir, ":t")
    raw_name = parent_name .. "/" .. project_name
  else
    raw_name = project_name
  end

  -- Sanitize the name for tmux: replace invalid characters (like '.') with an underscore
  return vim.fn.substitute(raw_name, '[\\.:]', '_', 'g')
end

local function show_sessionizer()
  -- 1. Find all project directories
  -- -----------------------------------------------------------------------
  local all_patterns = {}
  for _, marker in ipairs(config.file_markers) do
    table.insert(all_patterns, (marker:gsub("%.", "\\.")))
  end
  for _, marker in ipairs(config.regex_markers) do
    table.insert(all_patterns, marker)
  end
  local markers_regex = table.concat(all_patterns, "|")

  -- 2. Use tmux display-popup to run fzf
  -- -----------------------------------------------------------------------
  local find_cmd = string.format(
    "fd --max-depth 4 -H -I '^(%s)$' %s -X dirname | sort -u",
    markers_regex,
    config.search_dirs
  )

  local selected_path = fzf_tmux.tmux_popup(find_cmd, { fzf = true })

  -- If the user cancelled fzf, the file will be empty.
  if selected_path == "" then
    vim.notify("No project selected.", vim.log.levels.INFO)
    return
  end

  -- 3. Run tmux logic with the selected path (logic is unchanged)
  -- ---------------------------------------------------------------------
  local session_name = derive_session_name(selected_path)
  vim.fn.system("tmux has-session -t=" .. vim.fn.shellescape(session_name))

  if vim.v.shell_error ~= 0 then
    local create_cmd = string.format(
      "tmux new-session -ds %s -c %s",
      vim.fn.shellescape(session_name),
      vim.fn.shellescape(selected_path)
    )
    vim.fn.system(create_cmd)
  end

  vim.fn.system("tmux switch-client -t=" .. vim.fn.shellescape(session_name))
end

map({ 'n', 't' }, "<M-f>", show_sessionizer, { desc = "Open tmux sessionizer" })

map({ 'n', 't' }, '<M-g>', function()
  fzf_tmux.tmux_popup("lazygit")
end, { desc = 'Open lazygit in tmux popup' })


local function switch_tmux_session()
  -- This single command now gets the session list and pipes it directly into fzf
  local fzf_shell_command = "tmux list-sessions -F '#{session_name}'"

  local selected_session = fzf_tmux.tmux_popup(fzf_shell_command, { fzf = true, width = 80, height = 80 })

  -- If the user cancelled fzf, exit
  if selected_session == "" then
    vim.notify("No session selected.", vim.log.levels.INFO)
    return
  end

  -- 3. Switch to the selected tmux session
  vim.fn.system("tmux switch-client -t=" .. vim.fn.shellescape(selected_session))
end

map({ 'n', 't' }, '<M-s>', switch_tmux_session, { desc = 'Switch tmux session' })

vim.keymap.set("n", "<leader>sf", fzf_tmux.find_files, { desc = "[S]earch [F]iles (fzf)" })
vim.keymap.set("n", "<leader>sg", fzf_tmux.live_grep, { desc = "[S]earch by [G]rep (fzf)" })
