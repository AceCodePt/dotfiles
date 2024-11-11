local map = require("util.map").map

local M = {}

function M.init()
	map("n", "<leader>ti", ":TermExec cmd='terraform init'<CR>I", { silent = false })
	map("n", "<leader>tv", ":TermExec cmd='terraform validate'<CR>I", { silent = false })
	map("n", "<leader>tp", ":TermExec cmd='terraform plan'<CR>I", { silent = false })
	map("n", "<leader>ts", ":TermExec cmd='terraform show'<CR>I", { silent = false })
	map("n", "<leader>td", ":TermExec cmd='terraform destroy'<CR>I", { silent = false })
	map("n", "<leader>ta", ":TermExec cmd='terraform apply -auto-approve'<CR>I", { silent = false })
end

return M
