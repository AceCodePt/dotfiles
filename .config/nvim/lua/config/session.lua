local map = require("util.map").map

local config = {
  search_dir = vim.fn.expand("$HOME/**/companies"),

  -- Simple filenames. Dots will be escaped automatically.
  file_markers = {
    ".git",
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


local function show_sessionizer()
  local function derive_session_name(project_path)
    local parent_dir = vim.fn.fnamemodify(project_path, ":h")
    local project_name = vim.fn.fnamemodify(project_path, ":t")

    -- Check if the parent directory contains a bare git repository
    -- We look for any directory ending in '.git'
    local bare_repo_path = vim.fn.glob(parent_dir .. "/*.git", true, true)

    if #bare_repo_path > 0 then
      -- If a bare repo is found, use the parent directory name as the base
      local parent_name = vim.fn.fnamemodify(parent_dir, ":t")
      return parent_name .. "/" .. project_name
    else
      -- Otherwise, use the original project name
      return project_name
    end
  end
  -- 1. Find all project directories using 'fd'
  -- -----------------------------------------------------------------------
  -- Correct implementation
  local all_patterns = {}

  for _, marker in ipairs(config.file_markers) do
    -- The extra parentheses select only the first return value from gsub
    table.insert(all_patterns, (marker:gsub("%.", "\\.")))
  end

  for _, marker in ipairs(config.regex_markers) do
    table.insert(all_patterns, marker)
  end

  -- Join all patterns into the final regex string
  local markers_regex = table.concat(all_patterns, "|")
  -- Your 'find_cmd' using markers_regex...
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


  -- 2. Create the Telescope picker
  -- -----------------------------------------------------------------------
  local actions = require("telescope.actions")
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local previewers = require("telescope.previewers")
  local sorters = require("telescope.sorters")

  pickers.new({}, {
    prompt_title = "tmux Sessionizer",
    finder = finders.new_table({ results = projects }),
    sorter = sorters.get_generic_fuzzy_sorter(),

    -- Bonus: Add a previewer that lists the files in the selected directory
    previewer = previewers.new_buffer_previewer({
      title = "Directory Contents",
      get_buffer_by_name = function(_, entry) return entry.value end,
      define_preview = function(self, entry, _)
        local cmd = "ls -F " .. vim.fn.shellescape(entry.value)
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, vim.fn.systemlist(cmd))
      end,
    }),

    -- 3. Define the action to run on selection
    -- ---------------------------------------------------------------------
    attach_mappings = function(prompt_bufnr, _)
      actions.select_default:replace(function()
        local selection = require("telescope.actions.state").get_selected_entry()
        actions.close(prompt_bufnr)

        if not selection then return end
        local selected_path = selection.value

        -- Derive session name from directory name (e.g., my.project -> my_project)
        local session_name = derive_session_name(selected_path)

        -- Check if tmux session already exists
        vim.fn.system("tmux has-session -t=" .. vim.fn.shellescape(session_name))

        -- If not, create it as a new, detached session
        if vim.v.shell_error ~= 0 then
          local create_cmd = string.format(
            "tmux new-session -ds %s -c %s",
            vim.fn.shellescape(session_name),
            vim.fn.shellescape(selected_path)
          )
          vim.fn.system(create_cmd)
        end

        -- Switch the tmux client to the target session
        vim.fn.system("tmux switch-client -t=" .. vim.fn.shellescape(session_name))
      end)
      return true
    end,
  }):find()
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


-- Requires telescope.nvim
local function switch_tmux_session()
  -- 1. Get a list of all tmux session names
  local sessions = vim.fn.systemlist('tmux list-sessions -F "#S"')
  if vim.v.shell_error ~= 0 or #sessions == 0 then
    vim.notify("No active tmux sessions found.", vim.log.levels.WARN, { title = 'tmux' })
    return
  end

  -- 2. Use Telescope to create a fuzzy-findable list
  require('telescope.pickers').new({}, {
    prompt_title = 'tmux Sessions',
    finder = require('telescope.finders').new_table({
      results = sessions,
    }),
    sorter = require('telescope.config').values.generic_sorter({}),
    attach_mappings = function(prompt_bufnr)
      -- 3. Define what happens when you press Enter on a selection
      require('telescope.actions').select_default:replace(function()
        local selection = require('telescope.actions.state').get_selected_entry()
        require('telescope.actions').close(prompt_bufnr)

        if selection then
          -- 4. Build and run the command to switch to the selected session
          local session_name = selection.value
          vim.fn.system('tmux switch-client -t ' .. vim.fn.shellescape(session_name))
        end
      end)
      return true
    end,
  }):find()
end

map({ 'n', 't' }, '<M-s>', switch_tmux_session, { desc = 'Switch tmux session' })
