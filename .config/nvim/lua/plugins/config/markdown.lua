-- vim.api.nvim_create_autocmd('PackChanged', {
--   group = vim.api.nvim_create_augroup('MarkdownPreviewBuild', { clear = true }),
--   pattern = 'markdown-preview.nvim',
--   callback = function(args)
--     local plugin_path = args.data.path
--     vim.system({ 'yarn', 'install' }, {
--       cwd = plugin_path,
--       stdout = true,
--       stderr = true,
--     })
--   end
-- })

vim.g.mkdp_filetypes = { "markdown" }
vim.g.mkdp_echo_preview_url = 1
