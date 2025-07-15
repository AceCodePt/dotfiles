return {
  {
    "aserowy/tmux.nvim",
    opts =
        function()
          local tmux = require("tmux")
          tmux.setup(
            {
              copy_sync = {
                enable = false
              },
              resize = {
                enable_default_keybindings = false,
              },
            }
          )
        end
  },
}
