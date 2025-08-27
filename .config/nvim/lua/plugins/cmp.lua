vim.pack.add({
  { src = "https://github.com/Saghen/blink.cmp", tag = '1.*', }
})

require("blink.cmp").setup({
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
    default = { 'lsp', 'path', 'snippets', 'buffer' },
  },
  fuzzy = { implementation = "prefer_rust_with_warning" },
  signature = { enabled = true }
})
