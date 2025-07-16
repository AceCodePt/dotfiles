local map = require("util.map").map

local config = {
  -- Base directory to search for projects.
  search_dir = vim.fn.expand("$HOME/Desktop/companies"),

  -- Markers used by 'fd' to identify a project root.
  root_markers = {
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
}


local function show_sessionizer()
  -- 1. Find all project directories using 'fd'
  -- -----------------------------------------------------------------------
  local markers_regex = table.concat(config.root_markers, "|")
  local find_cmd = string.format(
    "fd --max-depth 4 --type f '^(%s)$' %s | xargs -I {} dirname {} | sort -u",
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
        local session_name = vim.fn.fnamemodify(selected_path, ":t"):gsub("[. ]", "_")

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


vim.keymap.set("n", "<M-f>", show_sessionizer, { desc = "Open tmux sessionizer" })


map('n', '<M-g>', function()
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

map('n', '<M-s>', switch_tmux_session, { desc = 'Switch tmux session' })
