-- lua/utils/fzf_tmux.lua

local M = {}

---A helper function to generate rg glob arguments from a list of patterns.
-- This translates Neovim's `file_ignore_patterns` table into `--glob` arguments for ripgrep.
-- @param ignore_patterns table: A list of file/directory patterns to ignore.
-- @return string: A string of `--glob '!pattern'` arguments.
local function get_rg_glob_args(ignore_patterns)
  local globs = {}
  for _, pattern in ipairs(ignore_patterns) do
    table.insert(globs, "--glob")
    table.insert(globs, "!" .. pattern)
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

  -- 1. The `rg` command that fzf's `reload` feature will execute on every keystroke.
  --    - `{q}` is the fzf placeholder for the user's current query.
  --    - `|| true` prevents fzf from exiting if `rg` finds no matches.
  local rg_reload_cmd = "rg --vimgrep -u --hidden " .. rg_glob_args .. " {q} || true"

  -- 2. The preview command using `bat` for syntax highlighting.
  --    - `fzf` splits the input `file:line:col:text` and passes the parts to the preview command.
  --    - `{1}` is the filename, `{2}` is the line number.
  local preview_cmd = "bat --style=numbers --color=always --highlight-line {2} {1}"

  -- 3. The full `fzf` command.
  --    - `change:reload(...)`: This is the magic for "live" grep. It re-runs the search on change.
  local fzf_shell_command = string.format(
    "fzf --ansi --delimiter ':' --preview %s --bind 'change:reload(%s)' --bind 'alt-j:down,alt-k:up' --prompt 'Live Grep > ' > %s",
    vim.fn.shellescape(preview_cmd),
    vim.fn.shellescape(rg_reload_cmd),
    vim.fn.shellescape(temp_file)
  )

  -- 4. Run the command in a tmux popup.
  local tmux_popup_command = "tmux display-popup -w80% -h80% -E " .. vim.fn.shellescape(fzf_shell_command)
  vim.fn.system(tmux_popup_command)

  -- 5. Read the selected line (e.g., "path/to/file:123:45:...") from the temp file.
  local selected_line = vim.trim((vim.fn.readfile(temp_file)[1] or ""))

  -- 6. Clean up.
  vim.loop.fs_unlink(temp_file)

  -- 7. Parse the selection and open the file at the correct line.
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
