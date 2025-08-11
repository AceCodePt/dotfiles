-- lua/utils/fzf_tmux.lua

local M = {}

---A helper function to generate rg glob arguments from a list of patterns.
-- This translates Neovim's `file_ignore_patterns` table into `--glob` arguments for ripgrep.
-- @param ignore_patterns table: A list of file/directory patterns to ignore.
-- @return string: A string of `--glob '!pattern'` arguments.
---A helper function to generate rg glob arguments from a list of patterns.
local function get_rg_glob_args(ignore_patterns)
  local globs = {}
  for _, pattern in ipairs(ignore_patterns) do
    table.insert(globs, "--glob")
    table.insert(globs, "\\!" .. pattern)
  end
  return table.concat(globs, " ")
end

-- Define ignore patterns based on your Telescope config.
-- These are used for both file finding and grepping.
local ignore_patterns = {
  ".git",
  "build",
  "dist",
  ".vercel",
  "node_modules",
  "yarn.lock",
  "pnpm-lock.yaml",
  "package-lock.json",
  "__pycache__",
  ".venv",
}
local rg_glob_args = get_rg_glob_args(ignore_patterns)

---Searches for files using ripgrep and fzf in a tmux popup.
-- Replicates Telescope's `find_files`.
function M.find_files()
  local temp_file = vim.fn.tempname()

  -- 1. Command to list files using `rg`, applying ignore patterns.
  --    This mirrors your `find_command` in Telescope.
  local list_files_cmd = "rg --files -u --hidden " .. rg_glob_args

  -- 2. Pipe the file list into fzf. The user's selection is written to a temp file.
  local fzf_shell_command = string.format(
    "%s | fzf --bind 'alt-j:down,alt-k:up' --prompt 'Search Files > ' > %s",
    list_files_cmd,
    vim.fn.shellescape(temp_file)
  )

  -- 3. Run the fzf command inside a tmux popup. The `-E` flag closes it on exit.
  local tmux_popup_command = "tmux display-popup -w60% -h60% -E " .. vim.fn.shellescape(fzf_shell_command)
  vim.fn.system(tmux_popup_command)

  -- 4. Read the selection from the temp file.
  local selected_file = vim.trim((vim.fn.readfile(temp_file)[1] or ""))

  -- 5. Clean up the temp file.
  vim.loop.fs_unlink(temp_file)

  -- 6. Open the selected file if one was chosen.
  if selected_file ~= "" then
    vim.cmd("edit " .. vim.fn.fnameescape(selected_file))
  else
    vim.notify("File search cancelled.", vim.log.levels.INFO)
  end
end

---Performs a live grep using ripgrep and fzf in a tmux popup.
-- Replicates Telescope's `live_grep` with a preview window.
function M.live_grep()
  local temp_file = vim.fn.tempname()

  -- The rg command is now constructed with \! escaped globs.
  local rg_reload_cmd = "rg --vimgrep -u --hidden " .. rg_glob_args .. " {q} || true"

  -- The fzf command structure remains the same. It correctly uses single quotes for the
  -- --bind argument, and the escaped globs inside will now work correctly.
  -- There are NO EXTRA QUOTES wrapped around the rg_reload_cmd.
  local fzf_shell_command = string.format(
    "fzf --ansi --delimiter ':' --bind 'change:reload(%s)' --bind 'alt-j:down,alt-k:up' --prompt 'Live Grep > ' > %s",
    rg_reload_cmd,
    vim.fn.shellescape(temp_file)
  )

  -- This part remains the same. vim.fn.shellescape correctly handles the whole fzf command string for tmux.
  local tmux_popup_command = "tmux display-popup -w80% -h80% -E " .. vim.fn.shellescape(fzf_shell_command)
  vim.fn.system(tmux_popup_command)

  -- Parsing the result remains the same.
  local selected_line = vim.trim((vim.fn.readfile(temp_file)[1] or ""))
  vim.loop.fs_unlink(temp_file)
  if selected_line ~= "" then
    local parts = vim.split(selected_line, ":", { plain = true, trimempty = true })
    local filename = parts[1]
    local line_number = parts[2]
    if filename and line_number then
      vim.cmd("edit +" .. line_number .. " " .. vim.fn.fnameescape(filename))
    else
      vim.notify("Could not parse fzf selection.", vim.log.levels.ERROR)
    end
  else
    vim.notify("Grep cancelled.", vim.log.levels.INFO)
  end
end

return M
