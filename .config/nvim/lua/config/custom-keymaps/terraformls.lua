local map = require("util.map").map

local M = {}

function M.init(bufnr)
	map("n", "<leader>ti", ":!terraform init<CR>", { bufnr = bufnr })
	map("n", "<leader>tv", ":!terraform validate<CR>", { bufnr = bufnr })
	map("n", "<leader>tp", ":!terraform plan<CR>", { bufnr = bufnr })
	map("n", "<leader>taa", ":!terraform apply -auto-approve<CR>", { bufnr = bufnr })
end

return M
