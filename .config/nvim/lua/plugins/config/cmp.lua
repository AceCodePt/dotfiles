local map = require("util.map").map
local fzf_tmux = require("util.fzf_tmux")
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
      menu = {
        auto_show = true,
        draw = {
          columns = {
            { "kind_icon" },
            { "label",      "label_description", gap = 1 },
            { "source_name" },
          },
        },
      },
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
        score_offset = 100,
      },
      lsp = {
        name = 'LSP',
        module = 'blink.cmp.sources.lsp',
        score_offset = 30,
        transform_items = function(ctx, items)
          local Kind = require('blink.cmp.types').CompletionItemKind
          local function norm(s) return (s or ""):gsub("%s+", "") end
          return vim.tbl_filter(function(item)
            if item.kind == Kind.Keyword then return false end
            local te = item.textEdit
            if not te then return true end
            local range = te.range or te.replace or te.insert
            if not range or range.start.line ~= range["end"].line then return true end
            local typed   = norm(ctx.line:sub(range.start.character + 1, ctx.cursor[2]))
            local newText = norm(te.newText or item.insertText or item.label)
            return newText:sub(1, #typed) == typed
          end, items)
        end,
      },
      path = {
        score_offset = 20,
        opts = {
          get_cwd = function(_)
            return vim.fn.getcwd()
          end,
        },
      },
      snippets = {
        score_offset = 30,
      },
      buffer = {
        score_offset = 10,
      },
    },
  },
  fuzzy = {
    implementation = 'prefer_rust',
    frecency = { enabled = false },
    sorts = {
      'exact',
      'score',
      'sort_text',
    }
  },
  signature = { enabled = true }
})

scissors.setup({
  snippetDir = snippet_dir,

  editSnippetPopup = {
    keymaps = {
      -- if not mentioned otherwise, the keymaps apply to normal mode
      cancel = ":q",
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
  { "n", "v" },
  "<leader>se",
  function()
    -- Grab items from scissors
    local convert = require("scissors.vscode-format.convert-object")
    local u = require("scissors.utils")
    local vb = require("scissors.vscode-format.validate-bootstrap")
    local editInPopup = require("scissors.3-edit-popup").editInPopup
    local snippetDir = require("scissors.config").config.snippetDir

    -- GUARD
    if not vb.validate(snippetDir) then return end
    local packageJsonExist = u.fileExists(snippetDir .. "/package.json")
    if not packageJsonExist then
      u.notify(
        "Your snippet directory is missing a `package.json`.\n"
        .. "The file can be bootstrapped by adding a new snippet via:\n"
        .. ":ScissorsAddNewSnippet",
        "warn"
      )
      return
    end

    -- GET ALL SNIPPETS
    local bufferFt = vim.bo.filetype
    local allSnippets = {} ---@type Scissors.SnippetObj[]
    local snippets_prefix_only = {} ---@type table<string>
    for _, absPath in pairs(convert.getSnippetfilePathsForFt(bufferFt)) do
      local filetypeSnippets = convert.readVscodeSnippetFile(absPath, bufferFt)
      vim.list_extend(allSnippets, filetypeSnippets)
    end
    for _, absPath in pairs(convert.getSnippetfilePathsForFt("all")) do
      local globalSnippets = convert.readVscodeSnippetFile(absPath, "plaintext")
      vim.list_extend(allSnippets, globalSnippets)
    end

    for index, item in ipairs(allSnippets) do
      table.insert(snippets_prefix_only, index .. ") " .. table.concat(item.prefix, ", "))
    end

    -- GUARD
    if #allSnippets == 0 then
      u.notify("No snippets found for filetype: " .. bufferFt, "warn")
      return
    end

    -- Run tmux popup over them
    -- get the selected item
    local selected_item = fzf_tmux.tmux_popup(snippets_prefix_only,
      { fzf = true, prompt = "Snippet > ", width = 50, height = 50 })
    if selected_item == "" then
      return
    end
    local number = tonumber(string.match(selected_item, "^%d+"))
    local snippet = allSnippets[number]
    editInPopup(snippet, "update")
  end,
  { desc = "Snippet: Edit" }
)

map(
  { "n", "x" },
  "<leader>sa",
  scissors.addNewSnippet,
  { desc = "Snippet: Add" }
)
