-- local map = require("util.map").map

return {
  fts = "tf",
  treesitter = "terraform",
  formatters = {},
  lsp = {
    name = "terraformls",
    config = {
      -- on_attach = function(_, bufnr)
      --   local prefix = "<leader>t"
      --   map("n", prefix .. "i", ":TermExec cmd='terraform init'<CR>I", { bufnr = bufnr })
      --   map("n", prefix .. "v", ":TermExec cmd='terraform validate'<CR>I", { bufnr = bufnr })
      --   map("n", prefix .. "p", ":TermExec cmd='terraform plan'<CR>I", { bufnr = bufnr })
      --   map("n", prefix .. "s", ":TermExec cmd='terraform show'<CR>I", { bufnr = bufnr })
      --   map("n", prefix .. "d", ":TermExec cmd='terraform destroy'<CR>I", { bufnr = bufnr })
      --   map("n", prefix .. "a", ":TermExec cmd='terraform apply -auto-approve'<CR>I", { bufnr = bufnr })
      -- end,
    }
  },
}
