local map = require("util.map").map
vim.pack.add({
  {
    -- cd ~/.local/share/nvim/site/pack/core/opt/blink.cmp && cargo build --release
    src = "https://github.com/Saghen/blink.cmp",
  },
  { src = "https://github.com/L3MON4D3/LuaSnip",          tag = "v2.*" },
  { src = "https://github.com/folke/lazydev.nvim" },
  { src = "https://github.com/chrisgrieser/nvim-scissors" }
})

local scissors = require("scissors")
local snippet_dir = vim.fn.stdpath("config") .. "/snippets"

require("luasnip.loaders.from_vscode").lazy_load({
  paths = snippet_dir
})

require("blink.cmp").setup({
  snippets = { preset = 'luasnip' },
  keymap = {
    preset = 'none',
    ['<M-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
    ['<M-e>'] = { 'hide' },
    ['<CR>'] = { 'accept', 'fallback' },
    ['<Tab>'] = {
      function(cmp)
        if cmp.snippet_active() then
          return cmp.accept()
        else
          return cmp.select_and_accept()
        end
      end,
      'snippet_forward',
      'fallback'
    },
    ['<M-k>'] = { 'select_prev', 'show' },
    ['<M-j>'] = { 'select_next', 'show' },
    ['<M-b>'] = { 'scroll_documentation_up', 'fallback' },
    ['<M-f>'] = { 'scroll_documentation_down', 'fallback' },
  },
  appearance = {
    nerd_font_variant = 'normal'
  },
  completion = {
    documentation = { auto_show = true, auto_show_delay_ms = 1 },
    list = {
      selection = {
        preselect = false,
        auto_insert = true
      }
    },
    ghost_text = { enabled = true },
  },
  cmdline = {
    keymap = {
      preset = 'inherit',
      ["<CR>"] = { "accept_and_enter", "fallback" },
    },
    completion = {
      menu = { auto_show = true },
      list = {
        selection = {
          preselect = function()
            return not vim.fn.getcmdtype():match("^[/?]")
          end,
          auto_insert = true
        }
      },
    },
  },
  sources = {
    default = { 'lazydev', 'lsp', 'path', 'snippets', 'buffer' },
    providers = {
      lazydev = {
        name = "LazyDev",
        module = "lazydev.integrations.blink",
        -- make lazydev completions top priority (see `:h blink.cmp`)
        score_offset = 100,
      },
    },
  },
  fuzzy = { implementation = "prefer_rust_with_warning" },
  signature = { enabled = true }
})

scissors.setup({
  snippetDir = snippet_dir,

  editSnippetPopup = {
    keymaps = {
      -- if not mentioned otherwise, the keymaps apply to normal mode
      cancel = "q",
      saveChanges = "<Esc>",
      goBackToSearch = "<BS>",
      deleteSnippet = "<A-BS>",
      duplicateSnippet = "<A-d>",
      openInFile = "<A-o>",
      insertNextPlaceholder = "<A-p>", -- insert & normal mode
      showHelp = "?",
    },
  },
})


map(
  "n",
  "<leader>se",
  scissors.editSnippet,
  { desc = "Snippet: Edit" }
)

map(
  { "n", "x" },
  "<leader>sa",
  scissors.addNewSnippet,
  { desc = "Snippet: Add" }
)
