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

--- This start a tmux popup with basic options
---@param command_or_table string | table<string>
---@param opts? {width?: number, height?: number, prompt?: string, reload_on_change?:boolean, fzf?:boolean}
---@return string
function M.tmux_popup(command_or_table, opts)
  if command_or_table == "" then
    error("Command can't be an empty string")
  end

  if type(command_or_table) == "table" and #command_or_table == 0 then
    error("Command can't be an empty table")
  end

  ---@type string
  local command
  if type(command_or_table) == "table" then
    command = "echo " .. vim.fn.shellescape(table.concat(command_or_table, "\n"))
  else
    command = command_or_table
  end


  opts = opts or {}
  local width = opts.width or 100
  local height = opts.height or 100


  local popup_command = ""
  local temp_file = ""
  if opts.fzf then
    local prompt = ""
    local reload_on_change = ""
    if opts.prompt then
      prompt = "--prompt " .. vim.fn.shellescape(opts.prompt)
    end
    if opts.reload_on_change then
      reload_on_change = "--bind 'change:reload(" .. command .. ")'"
    end
    temp_file = vim.fn.tempname()
    popup_command = string.format(" | fzf --bind 'alt-j:down,alt-k:up' %s %s > %s",
      reload_on_change,
      prompt,
      vim.fn.shellescape(temp_file)
    )
  end

  local fzf_command = string.format("%s" .. popup_command,
    command
  )

  local tmux_popup_command =
      "tmux display-popup " ..
      "-w" .. width .. "% " ..
      "-h" .. height .. "% " ..
      "-E " .. vim.fn.shellescape(fzf_command)
  vim.fn.system(tmux_popup_command)

  if temp_file == "" then
    return ""
  end
  local result = vim.trim((vim.fn.readfile(temp_file)[1] or ""))
  return result
end

---Searches for files using ripgrep and fzf in a tmux popup.
-- Replicates Telescope's `find_files`.
function M.find_files()
  local list_files_cmd = "rg --files -u --hidden " .. rg_glob_args

  local selected_file = M.tmux_popup(list_files_cmd, { fzf = true, prompt = "Find Files > ", width = 60, height = 60 })

  if selected_file ~= "" then
    vim.cmd("edit " .. vim.fn.fnameescape(selected_file))
  else
    vim.notify("File search cancelled.", vim.log.levels.INFO)
  end
end

---Performs a live grep using ripgrep and fzf in a tmux popup.
-- Replicates Telescope's `live_grep` with a preview window.
function M.live_grep()
  -- The rg command is now constructed with \! escaped globs.
  local rg_reload_cmd = "rg --vimgrep -u --hidden " .. rg_glob_args .. " {q} || true"

  local selected_line = M.tmux_popup(rg_reload_cmd,
    { fzf = true, prompt = "Grep Files > ", width = 80, height = 80, reload_on_change = true })

  -- Parsing the result remains the same.
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
