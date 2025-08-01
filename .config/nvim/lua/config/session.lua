local map = require("util.map").map

local config = {
  search_dir = vim.fn.expand("$HOME/companies"),

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
  -- 1. Find all project directories (logic is unchanged)
  -- -----------------------------------------------------------------------
  local all_patterns = {}
  for _, marker in ipairs(config.file_markers) do
    table.insert(all_patterns, (marker:gsub("%.", "\\.")))
  end
  for _, marker in ipairs(config.regex_markers) do
    table.insert(all_patterns, marker)
  end
  local markers_regex = table.concat(all_patterns, "|")
  local find_cmd = string.format(
    "fd --max-depth 4 -H '^(%s)$' %s -X dirname | sort -u",
    markers_regex,
    vim.fn.shellescape(config.search_dir)
  )
  local projects = vim.fn.systemlist(find_cmd)

  if vim.v.shell_error ~= 0 or #projects == 0 then
    vim.notify("No projects found in " .. config.search_dir, vim.log.levels.WARN)
    return
  end

  -- 2. Use tmux display-popup to run fzf
  -- -----------------------------------------------------------------------
  local temp_file = vim.fn.tempname()
  local fzf_input = table.concat(projects, "\n")

  -- This is the shell command that will run inside the popup.
  -- It pipes the project list to fzf and writes the selection to a temp file.
  local fzf_shell_command = string.format(
    "printf %s | fzf --bind 'alt-j:down,alt-k:up' > %s",
    vim.fn.shellescape(fzf_input),
    vim.fn.shellescape(temp_file)
  )

  -- This is the final command Neovim will execute.
  -- -E makes the popup block until the command inside it finishes.
  local tmux_popup_command = "tmux display-popup -w100% -h100% -E " .. vim.fn.shellescape(fzf_shell_command)

  vim.fn.system(tmux_popup_command)

  -- Read the selection from the temp file. The `or ""` handles empty files.
  local selected_path = vim.trim((vim.fn.readfile(temp_file)[1] or ""))

  -- Clean up the temporary file
  vim.loop.fs_unlink(temp_file)

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
  -- Get the current working directory from Neovim
  local cwd = vim.fn.getcwd()

  -- Build the full tmux command with the correct directory
  local command = 'tmux display-popup -d '
      .. vim.fn.shellescape(cwd)
      .. ' -w100% -h100% -E lazygit'
  -- Run the command
  vim.fn.system(command)
end, { desc = 'Open lazygit in tmux popup' })


local function switch_tmux_session()
  -- 1. Get a list of currently running tmux sessions
  local sessions = vim.fn.systemlist("tmux list-sessions -F '#{session_name}'")

  -- Exit if there are no sessions to switch to
  if #sessions == 0 then
    vim.notify("No running tmux sessions.", vim.log.levels.INFO)
    return
  end

  -- 2. Use tmux display-popup to run fzf
  local temp_file = vim.fn.tempname()
  local fzf_input = table.concat(sessions, "\n")

  -- The shell command that will run inside the popup
  local fzf_shell_command = string.format(
    "printf '%%b' %s | fzf --bind 'alt-j:down,alt-k:up' > %s",
    vim.fn.shellescape(fzf_input),
    vim.fn.shellescape(temp_file)
  )

  -- The final command Neovim will execute
  local tmux_popup_command = "tmux display-popup -w50% -h50% -E " .. vim.fn.shellescape(fzf_shell_command)

  vim.fn.system(tmux_popup_command)

  -- Read the selection from the temp file
  local selected_session = vim.trim((vim.fn.readfile(temp_file)[1] or ""))

  -- Clean up the temporary file
  vim.loop.fs_unlink(temp_file)

  -- If the user cancelled fzf, exit
  if selected_session == "" then
    vim.notify("No session selected.", vim.log.levels.INFO)
    return
  end

  -- 3. Switch to the selected tmux session
  vim.fn.system("tmux switch-client -t=" .. vim.fn.shellescape(selected_session))
end

map({ 'n', 't' }, '<M-s>', switch_tmux_session, { desc = 'Switch tmux session' })
