return {version=12,pkgs={{dir="/data/data/com.termux/files/home/.local/share/nvim/lazy/noice.nvim",spec=function()
return {
  -- nui.nvim can be lazy loaded
  { "MunifTanjim/nui.nvim", lazy = true },
  {
    "folke/noice.nvim",
  },
}

end,name="noice.nvim",file="lazy.lua",source="lazy",},{dir="/data/data/com.termux/files/home/.local/share/nvim/lazy/plenary.nvim",spec={"nvim-lua/plenary.nvim",lazy=true,},name="plenary.nvim",file="community",source="lazy",},{dir="/data/data/com.termux/files/home/.local/share/nvim/lazy/telescope.nvim",spec={"telescope.nvim",specs={{"nvim-lua/plenary.nvim",lazy=true,},},build=false,},name="telescope.nvim",file="telescope.nvim-scm-1.rockspec",source="rockspec",},},}