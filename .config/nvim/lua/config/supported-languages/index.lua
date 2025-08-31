local M = {}

local function get_current_file()
  local info = debug.getinfo(1, "S")
  -- The `source` field contains the file path
  local normalized = string.gsub(info.source, "^@", "")
  return normalized
end

local function get_files_in_current_dir()
  -- Get the full path of the current file's directory
  local current_dir = vim.fn.fnamemodify(get_current_file(), ":h")

  -- Check if we are in a valid directory
  if not current_dir or current_dir == '' then
    print('Not in a valid directory.')
    return {}
  end

  local files = {}

  for entry in vim.fs.dir(current_dir) do
    table.insert(files, entry)
  end

  return files
end

local function get_module_by_ft()
  local lua_files = get_files_in_current_dir()

  -- Check if any files were found
  if #lua_files == 0 then
    vim.notify("No Lua files found in '" .. "'.", vim.log.levels.INFO)
    return {}
  end

  -- A table to hold the final results (file names without the suffix)
  local mod_by_ft = {}

  -- Iterate over the list of found file paths to filter out index.lua and process the names
  for _, file_name in ipairs(lua_files) do
    -- Exclude the 'index.lua' file
    if file_name ~= "index.lua" then
      local name_without_suffix = string.gsub(file_name, "%.lua$", "")
      local mod_name = "config.supported-languages." .. name_without_suffix
      local ok, mod = pcall(require, mod_name)

      if ok and mod then
        mod_by_ft[name_without_suffix] = mod
      end
    end
  end
  return mod_by_ft
end

function M.get_formatters_by_ft()
  local mod_by_ft = get_module_by_ft()

  -- A table to hold the final results (file names without the suffix)
  local formatters_by_ft = {}

  -- Iterate over the list of found file paths to filter out index.lua and process the names
  for ft, mod in pairs(mod_by_ft) do
    formatters_by_ft[ft] = mod.formatters
  end
  return formatters_by_ft
end

function M.get_lsp_by_ft()
  local mod_by_ft = get_module_by_ft()

  -- A table to hold the final results (file names without the suffix)
  local lsp_by_ft = {}

  -- Iterate over the list of found file paths to filter out index.lua and process the names
  for ft, mod in pairs(mod_by_ft) do
    lsp_by_ft[ft] = mod.lsp
  end
  return lsp_by_ft
end

function M.get_treesitters()
  local mod_by_ft = get_module_by_ft()

  -- A table to hold the final results (file names without the suffix)
  ---@type table<string>
  local treesitters = {}

  -- Iterate over the list of found file paths to filter out index.lua and process the names
  for _, mod in pairs(mod_by_ft) do
    if type(mod.treesitter) == "table" then
      vim.list_extend(treesitters, mod.treesitter)
    elseif type(mod.treesitter) == "string" then
      vim.list_extend(treesitters, { mod.treesitter })
    end
  end
  return treesitters
end

return M
