vim.pack.add({
  { src = "https://github.com/neovim/nvim-lspconfig" },
  { src = "https://github.com/mason-org/mason.nvim" },
})

local supported_languages = require("config.supported-languages")

require("mason").setup({})
local _ = require "mason-core.functional"
local registry = require "mason-registry"

local cached_specs = _.lazy(registry.get_all_package_specs)
registry:on("update:success", function()
  cached_specs = _.lazy(registry.get_all_package_specs)
end)

local function get_lspconfig_to_package()
  ---@type table<string, string>
  local lspconfig_to_package = {}
  for _, pkg_spec in ipairs(cached_specs()) do
    local lspconfig = vim.tbl_get(pkg_spec, "neovim", "lspconfig")
    if lspconfig then
      lspconfig_to_package[lspconfig] = pkg_spec.name
    end
  end

  return lspconfig_to_package
end

local lspconfig_to_package = get_lspconfig_to_package()
for _, lang in pairs(supported_languages) do
  local opts = {}
  local pkg_name = lspconfig_to_package[lang.lsp.name]
  local pkg = registry.get_package(pkg_name)

  -- ensure installed
  if pkg and not pkg:is_installed() then
    pkg:install()
  end

  -- Merge custom config if it exists
  if lang.lsp.config then
    opts = vim.tbl_deep_extend("force", opts, lang.lsp.config)
    if lang.lsp.config.on_attach then
      opts.on_attach = function(client, bufnr)
        lang.lsp.config.on_attach(client, bufnr)
      end
    end
  end

  -- Set up the LSP server
  vim.lsp.config(lang.lsp.name, opts)
  vim.lsp.enable(lang.lsp.name)
end

vim.diagnostic.config({
  virtual_lines = false,
  virtual_text = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})
