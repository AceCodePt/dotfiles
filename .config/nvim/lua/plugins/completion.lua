return {
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-nvim-lua",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"hrsh7th/cmp-buffer",
			{
				"L3MON4D3/LuaSnip",
				version = "v2.*",
				build = "make install_jsregexp",
			},
			"saadparwaiz1/cmp_luasnip",
		},
		opts = function(_, opts)
			opts.sources = opts.sources or {}
			table.insert(opts.sources, {
				name = "lazydev",
				group_index = 0, -- set group index to 0 to skip loading LuaLS completions
			})
		end,
		config = function()
			local map = require("util.map").map
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			-- local types = require("cmp.types")
			local compare = require("cmp.config.compare")

			vim.keymap.set({ "i", "s" }, "<C-l>", function()
				luasnip.jump(1)
			end, { silent = true })
			vim.keymap.set({ "i", "s" }, "<C-h>", function()
				luasnip.jump(-1)
			end, { silent = true })

			cmp.setup.filetype({ "sql" }, {
				sources = {
					{ name = "vim-dabod-completion" },
					{ name = "buffer" },
				},
			})

			-- local modified_priority = {
			-- 	[types.lsp.CompletionItemKind.Variable] = 1,
			-- 	[types.lsp.CompletionItemKind.Method] = 2,
			-- 	[types.lsp.CompletionItemKind.Snippet] = 0, -- top
			-- 	[types.lsp.CompletionItemKind.Keyword] = 3,
			-- 	[types.lsp.CompletionItemKind.Text] = 100, -- bottom
			-- }

			-- local function modified_kind(kind)
			-- 	return modified_priority[kind] or kind
			-- end

			cmp.setup({
				preselect = cmp.PreselectMode.Item,
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
					end,
				},
				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},
				completion = {
					completeopt = "menu,menuone,noinsert",
				},
				mapping = cmp.mapping.preset.insert({
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-j>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "c" }),
					["<C-k>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "c" }),
					["<CR>"] = cmp.mapping(
						cmp.mapping.confirm({
							behavior = cmp.ConfirmBehavior.Replace,
							select = true,
						}),
						{ "i" }
					),
					["<C-Space>"] = cmp.mapping.complete({}),
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp", priority = 8 },
					{ name = "luasnip", priority = 8 },
					{ name = "buffer", priority = 7 }, -- first for locality sorting?
					{ name = "spell", keyword_length = 3, priority = 5, keyword_pattern = [[\w\+]] },
					{ name = "nvim_lua", priority = 5 },
					{ name = "calc", priority = 3 },
				}),
				enabled = function()
					-- disable completion in comments
					local context = require("cmp.config.context")

					-- keep command mode completion enabled
					if vim.api.nvim_get_mode().mode == "c" then
						return true
					else
						return not context.in_treesitter_capture("comment") and not context.in_syntax_group("Comment")
					end
				end,
				formatting = {
					format = function(_, vim_item)
						local kind_icons = vim.g.personal_options.lsp_icons
						vim_item.kind = string.format("%s %s", kind_icons[vim_item.kind], vim_item.kind)
						-- I don't want to see any menu items
						vim_item.menu = ""
						return vim_item
					end,
				},
				sorting = {
					priority_weight = 1,
					-- https://github.com/hrsh7th/nvim-cmp/blob/main/lua/cmp/config/compare.lua
					comparators = {
						-- compare.exact,
						-- compare.offset,
						compare.score,
						-- function(entry1, entry2) -- sort by compare kind (Variable, Function etc)
						-- 	local kind1 = modified_kind(entry1:get_kind())
						-- 	local kind2 = modified_kind(entry2:get_kind())
						-- 	if kind1 ~= kind2 then
						-- 		return kind1 - kind2 < 0
						-- 	end
						-- end,
						compare.locality,
						-- compare.recently_used,
					},
				},
			})

			cmp.setup.cmdline({ "/", "?" }, {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = "buffer" },
				},
			})

			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
			})

			map("n", "<leader>ls", function()
				require("luasnip.loaders.from_vscode").load({ paths = { "./snippets" } })
			end, { desc = "Update luasnipt" })
			require("luasnip.loaders.from_vscode").lazy_load({ paths = { "./snippets" } })
		end,
	},
}
