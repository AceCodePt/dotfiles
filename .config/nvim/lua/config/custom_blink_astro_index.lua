--- @module 'blink.cmp'
--- @class blink.cmp.Source
local source = {}

-- A cache for tsconfig.json parsing, per project root
local tsconfig_cache = {}

-- ----------------------------------------------------------------------------
-- Default Config & Helpers
-- ----------------------------------------------------------------------------

---@class AstroIndexConfig
local C = {
  ---The directory to scan for components, relative to the project root.
  component_dir = "/src/components",
  ---The completion item kind.
  kind = require('blink.cmp.types').CompletionItemKind.Class,
  ---Debug mode for logging.
  debug = true,
}

---@param self { opts: AstroIndexConfig }
local function log(self, msg)
  if self.opts and self.opts.debug then
    print("[blink_astro_index] " .. msg)
  end
end

-- ----------------------------------------------------------------------------
-- Path Utility Functions
-- ----------------------------------------------------------------------------

---Finds the project root.
---@return string
local function get_project_root(self)
  local git_dir = vim.fn.finddir('.git', '.;')
  if git_dir ~= '' then
    local root_path = vim.fn.fnamemodify(git_dir, ':p:h:h')
    log(self, "[get_project_root] Found .git, root is: " .. root_path)
    return root_path
  end

  local package_json = vim.fn.findfile('package.json', '.;')
  if package_json ~= '' then
    local root_path = vim.fn.fnamemodify(package_json, ':p:h')
    log(self, "[get_project_root] Found package.json, root is: " .. root_path)
    return root_path
  end

  local cwd = vim.fn.getcwd()
  log(self, "[get_project_root] No root markers found. Using cwd: " .. cwd)
  return cwd
end

---
--- NEW ROBUST HELPER: Gets a relative path using only vim.fn
---
---@param to_path string
---@param from_path string
---@param self table
---@return string
local function get_relative_path(to_path, from_path, self)
  log(self, "[get_relative_path] Getting path for '" .. to_path .. "' relative to '" .. from_path .. "'")

  -- Get the absolute, canonical path of the 'from' directory
  local abs_from_path = vim.fn.fnamemodify(from_path, ':p')
  log(self, "[get_relative_path] Absolute 'from_path': " .. abs_from_path)

  -- Get the absolute, canonical path of the 'to' file
  local abs_to_path = vim.fn.fnamemodify(to_path, ':p')
  log(self, "[get_relative_path] Absolute 'to_path': " .. abs_to_path)

  -- Use :. to get the path relative to the 'from' directory
  local rel_path = vim.fn.fnamemodify(abs_to_path, ':.' .. abs_from_path)
  log(self, "[get_relative_path] Generated rel_path (from fnamemodify): " .. rel_path)

  -- Add ./ if it's just a filename (e.g., "MainSection.astro")
  if not rel_path:match('^%.%./') and not rel_path:match('^%./') then
    log(self, "[get_relative_path] Path needs './' prefix.")
    rel_path = './' .. rel_path
  end

  log(self, "[get_relative_path] Final rel_path: " .. rel_path)
  return rel_path
end


---Reads and parses tsconfig.json to find the baseUrl.
---@param project_root string
---@param self table
---@return string
local function get_tsconfig_base_url(project_root, self)
  if tsconfig_cache[project_root] then
    log(self, "[tsconfig] Using cached baseUrl: '" .. tsconfig_cache[project_root] .. "'")
    return tsconfig_cache[project_root]
  end

  local base_url_to_cache = "."
  local tsconfig_path = project_root .. "/tsconfig.json"
  log(self, "[tsconfig] Looking for: " .. tsconfig_path)

  if vim.fn.filereadable(tsconfig_path) == 1 then
    log(self, "[tsconfig] Found. Reading file.")
    local content = table.concat(vim.fn.readfile(tsconfig_path), "\n")

    log(self, "[tsconfig] Stripping comments...")
    content = content:gsub("//[^\n]*", "") -- Strip line comments
    content = content:gsub("/%*.-%*/", "") -- Strip block comments (non-greedy)

    log(self, "[tsconfig] Stripped content, parsing JSON...")

    local ok, parsed = pcall(vim.fn.json_decode, content)

    if not ok then
      log(self, "[tsconfig] ERROR: Failed to parse tsconfig.json. " .. tostring(parsed))
    elseif parsed and parsed.compilerOptions and parsed.compilerOptions.baseUrl then
      local found_base_url = parsed.compilerOptions.baseUrl
      if found_base_url ~= vim.NIL then
        log(self, "[tsconfig] Found baseUrl: '" .. found_base_url .. "'")
        base_url_to_cache = found_base_url
      else
        log(self, "[tsconfig] Found baseUrl: null. Using default '.'")
      end
    else
      log(self, "[tsconfig] No 'compilerOptions.baseUrl' found. Using default '.'")
    end
  else
    log(self, "[tsconfig] No tsconfig.json found. Using default '.'")
  end

  tsconfig_cache[project_root] = base_url_to_cache
  return base_url_to_cache
end


---Calculates the file-relative import path (e.g., ../../Comp.astro)
---@param component_path string
---@param self table
---@return string
local function get_relative_import_path(component_path, self)
  local current_bufnr = vim.api.nvim_get_current_buf()
  local current_file_path = vim.api.nvim_buf_get_name(current_bufnr)
  local current_dir

  log(self, "[get_relative_import_path] --- Start ---")
  log(self, "[get_relative_import_path] Current file path: " .. tostring(current_file_path))

  if current_file_path == "" then
    current_dir = vim.fn.getcwd()
    log(self, "[get_relative_import_path] Buffer is unnamed. Using cwd: " .. current_dir)
  else
    current_dir = vim.fn.fnamemodify(current_file_path, ':p:h')
    log(self, "[get_relative_import_path] Using file's directory: " .. current_dir)
  end

  -- Use the new robust helper
  local rel_path = get_relative_path(component_path, current_dir, self)

  log(self, "[get_relative_import_path] Final relative path: " .. rel_path)
  log(self, "[get_relative_import_path] --- End ---")
  return rel_path
end

---Uses the robust tsconfig logic
---@param project_root string
---@param component_path string
---@param self table
---@return string | nil
local function get_base_url_import_path(project_root, component_path, self)
  local base_url = get_tsconfig_base_url(project_root, self)

  -- Use the new robust helper
  local path_from_root = get_relative_path(component_path, project_root, self)

  log(self, "[get_base_url_import_path] path_from_root: " .. path_from_root)
  log(self, "[get_base_url_import_path] baseUrl is: '" .. base_url .. "'")

  if base_url == "." or base_url == "./" then
    -- Strip the leading './' (e.g., "./src/components..." -> "src/components...")
    local final_path = path_from_root:gsub('^%./', '')
    log(self, "[get_base_url_import_path] Using path_from_root (stripped): " .. final_path)
    return final_path
  end

  local prefix_pattern = base_url:gsub("([^%w])", "%%%1") .. "/"
  local match_pattern = '^%./' .. prefix_pattern -- e.g., ^\./src/

  if path_from_root:match(match_pattern) then
    local final_path = path_from_root:gsub(match_pattern, '')
    log(self, "[get_base_url_import_path] Stripped './" .. prefix_pattern .. "'. Path is: " .. final_path)
    return final_path
  end

  if path_from_root:match('^' .. prefix_pattern) then
    local final_path = path_from_root:gsub('^' .. prefix_pattern, '')
    log(self, "[get_base_url_import_path] Stripped '" .. prefix_pattern .. "'. Path is: " .. final_path)
    return final_path
  end

  log(self,
    "[get_base_url_import_path] baseUrl ('" .. base_url .. "') did not match path. Returning root path (stripped).")
  return (path_from_root:gsub('^%./', ''))
end

-- ----------------------------------------------------------------------------
-- Astro-Specific Helper Functions
-- ----------------------------------------------------------------------------

---Finds the line to insert the import on.
---@param bufnr number
---@return number
local function get_import_insert_line(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, 100, false)
  if #lines == 0 or lines[1] ~= '---' then
    return 0 -- No frontmatter, insert at top
  end

  for i = 2, #lines do
    if lines[i]:match('^---$') then
      return i - 1 -- Insert before the closing '---'
    end
  end
  return 1 -- No closing '---', insert after opening '---'
end

---NEW: Escapes a string for use in a Lua pattern.
---@param str string
---@return string
local function escape_lua_pattern(str)
  return (str:gsub("([%(%)%.%%%+%-%*%?%[%^%$])", "%%%1"))
end

---NEW: Checks if a file path is already in an import statement.
---@param bufnr number
---@param path1 string | nil
---@param path2 string | nil
---@param self table
---@return boolean
local function is_path_already_imported(bufnr, path1, path2, self)
  local end_line = get_import_insert_line(bufnr)
  if end_line == 0 then
    log(self, "[is_path_already_imported] No frontmatter, file is not imported.")
    return false
  end

  -- Read lines *up to and including* the insert line
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, end_line + 1, false)

  local patterns = {}
  if path1 then
    --
    -- THE FIX: Use Lua pattern escaper
    --
    table.insert(patterns, escape_lua_pattern(path1))
  end
  if path2 then
    --
    -- THE FIX: Use Lua pattern escaper
    --
    table.insert(patterns, escape_lua_pattern(path2))
  end

  if #patterns == 0 then
    log(self, "[is_path_already_imported] No valid paths to check.")
    return false
  end

  local combined_pattern = table.concat(patterns, "|")
  -- Final regex: looks for 'from' then ' or " then (one of our paths)
  local search_pattern = "from%s*['\"](" .. combined_pattern .. ")['\"]"

  log(self, "[is_path_already_imported] Scanning for pattern: " .. search_pattern)

  for i, line in ipairs(lines) do
    if line:match(search_pattern) then
      log(self, "[is_path_already_imported] Found existing import of this file on line " .. i)
      return true
    end
  end

  log(self, "[is_path_already_imported] No existing import found.")
  return false
end

---Gets the component's name from its file path.
---@param file_path string
---@return string | nil
local function get_component_name_from_path(file_path)
  local component_name
  local filename = vim.fn.fnamemodify(file_path, ':t')

  if filename == 'index.astro' then
    component_name = vim.fn.fnamemodify(vim.fn.fnamemodify(file_path, ':h'), ':t')
  else
    component_name = vim.fn.fnamemodify(filename, ':r')
  end

  local first_char = string.sub(component_name, 1, 1)
  if first_char == string.upper(first_char) and first_char ~= '_' then
    return component_name
  end

  return nil
end

-- ----------------------------------------------------------------------------
-- Blink Source Implementation
-- ----------------------------------------------------------------------------

function source.new(opts)
  local self = setmetatable({}, { __index = source })
  self.opts = vim.tbl_deep_extend('force', vim.deepcopy(C), opts or {})
  self.opts.debug = true
  log(self, "Source initialized. Debug is ON.")
  return self
end

function source:enabled()
  local ft = vim.bo.filetype
  return ft == 'astro' or ft == 'mdx'
end

function source:get_trigger_characters()
  return { '<' }
end

function source:get_completions(ctx, callback)
  log(self, "get_completions triggered for: " .. (ctx.keyword or ""))

  local root_dir = get_project_root(self)
  if root_dir == '' then
    log(self, "No project root found.")
    return callback({ items = {} })
  end

  local component_scan_dir = root_dir .. self.opts.component_dir
  log(self, "Scanning directory: " .. component_scan_dir)

  local astro_files = vim.fn.globpath(component_scan_dir, '**/*.astro', true, true)

  if vim.tbl_isempty(astro_files) then
    log(self, "No '.astro' files found.")
    return callback({ items = {} })
  end

  --- @type lsp.CompletionItem[]
  local items = {}

  for _, file_path in ipairs(astro_files) do
    local component_name = get_component_name_from_path(file_path)

    if component_name then
      --- @type lsp.CompletionItem
      local item = {
        label = component_name,
        kind = self.opts.kind,
        detail = 'Astro Component',
        data = {
          full_path = file_path,
          component_name = component_name,
          project_root = root_dir,
        },
      }
      table.insert(items, item)
    end
  end

  log(self, "Found " .. #items .. " components.")
  callback({
    items = items,
    is_incomplete_backward = false,
    is_incomplete_forward = false,
  })
end

function source:resolve(item, callback)
  log(self, "--- Resolving item: " .. item.label .. " ---")
  item = vim.deepcopy(item)

  local current_bufnr = vim.api.nvim_get_current_buf()

  -- First, generate both potential paths
  local base_url_path = get_base_url_import_path(item.data.project_root, item.data.full_path, self)
  local relative_path = get_relative_import_path(item.data.full_path, self)

  -- Check if the file is already imported
  if is_path_already_imported(current_bufnr, base_url_path, relative_path, self) then
    log(self, "[resolve] Component file is already imported. Skipping text edits.")
    item.documentation = {
      kind = 'markdown',
      value = string.format("### %s\n\n(File is already imported)", item.label),
    }
    callback(item) -- Return item *without* additionalTextEdits
    return
  end

  -- If not imported, proceed with generating the import
  local import_path

  if base_url_path then
    log(self,
      "[resolve] Comparing paths: base_url_len(" ..
      string.len(base_url_path) .. ") < relative_len(" .. string.len(relative_path) .. ")")
    if string.len(base_url_path) < string.len(relative_path) then
      import_path = base_url_path
      log(self, "[resolve] Decision: Using shorter base-url path: " .. import_path)
    else
      import_path = relative_path
      log(self, "[resolve] Decision: Using file-relative path (it's shorter or equal): " .. import_path)
    end
  else
    import_path = relative_path
    log(self, "[resolve] Decision: No base_url_path found. Using file-relative path: " .. import_path)
  end

  local import_statement = string.format("import %s from '%s'\n", item.data.component_name, import_path)
  local insert_line = get_import_insert_line(current_bufnr)

  item.documentation = {
    kind = 'markdown',
    value = string.format("### %s\n\nAuto-imports from:\n```astro\n%s\n```", item.label, import_path),
  }

  item.additionalTextEdits = {
    {
      newText = import_statement,
      range = {
        start = { line = insert_line, character = 0 },
        ['end'] = { line = insert_line, character = 0 },
      },
    },
  }

  callback(item)
end

return source
