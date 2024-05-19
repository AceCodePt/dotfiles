return {
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-nvim-lua",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"hrsh7th/cmp-buffer",
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			local types = require("cmp.types")
			local compare = require("cmp.config.compare")

			vim.keymap.set({ "i", "s" }, "<C-L>", function()
				luasnip.jump(1)
			end, { silent = true })
			vim.keymap.set({ "i", "s" }, "<C-J>", function()
				luasnip.jump(-1)
			end, { silent = true })

			local modified_priority = {
				[types.lsp.CompletionItemKind.Variable] = types.lsp.CompletionItemKind.Method,
				[types.lsp.CompletionItemKind.Snippet] = 0, -- top
				[types.lsp.CompletionItemKind.Keyword] = 1, -- top
				[types.lsp.CompletionItemKind.Text] = 100, -- bottom
			}

			local function modified_kind(kind)
				return modified_priority[kind] or kind
			end

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
				mapping = cmp.mapping.preset.insert({
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<C-j>"] = cmp.mapping.select_next_item(),
					["<C-k>"] = cmp.mapping.select_prev_item(),
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "nvim_lua" },
					{ name = "buffer" },
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
					-- https://github.com/hrsh7th/nvim-cmp/blob/main/lua/cmp/config/compare.lua
					comparators = {
						compare.offset,
						compare.exact,
						compare.scopes,
						compare.length,
						-- function(entry1, entry2) -- sort by length ignoring "=~"
						-- 	local len1 = string.len(string.gsub(entry1.completion_item.label, "[=~()_]", ""))
						-- 	local len2 = string.len(string.gsub(entry2.completion_item.label, "[=~()_]", ""))
						-- 	if len1 ~= len2 then
						-- 		return len1 - len2 < 0
						-- 	end
						-- end,
						compare.recently_used,
						function(entry1, entry2) -- sort by compare kind (Variable, Function etc)
							local kind1 = modified_kind(entry1:get_kind())
							local kind2 = modified_kind(entry2:get_kind())
							if kind1 ~= kind2 then
								return kind1 - kind2 < 0
							end
						end,
						compare.sort_text,
						compare.score,
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

			require("luasnip.loaders.from_vscode").lazy_load({ paths = { "./snippets" } })
		end,
	},
}
