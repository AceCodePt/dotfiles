local M = {}


local plugins_dir_definition = "plugins"
local plugins_dir_config = "plugins.config"
local dir = vim.fn.stdpath("config") .. "/lua/" .. plugins_dir_definition
local spec = {}


local function fn_plugin_config(plugin_name, plugin_dir_config)
  return function()
    local plugin_config = plugin_dir_config .. "." .. plugin_name
    local ok, _ = pcall(require, plugin_config)
    if not ok then
      error("Didn't find, " .. plugin_config)
    end
  end
end


function M.get_lazy_spec()
  for entry in vim.fs.dir(dir) do
    local plugin_name = entry:gsub(".lua$", "")
    local plugin_path = plugins_dir_definition .. "." .. plugin_name
    local ok, mod = pcall(require, plugin_path)
    if ok then
      if not mod.config then
        mod.config = fn_plugin_config(plugin_name, plugins_dir_config)
      end
      table.insert(spec, mod)
    end
  end

  return spec
end

return M
