return {
  -- cd ~/.local/share/nvim/site/pack/core/opt/blink.cmp && cargo build --release
  url = "https://github.com/Saghen/blink.cmp",
  build = 'cargo build --release',
  dependencies = {
    { url = "https://github.com/L3MON4D3/LuaSnip",  tag = "v2.*" },
    { url = "https://github.com/folke/lazydev.nvim" },
    { url = "https://github.com/chrisgrieser/nvim-scissors" }
  }
}
