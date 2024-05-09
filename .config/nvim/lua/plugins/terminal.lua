return {
  {
    'AceCodePt/terminal.nvim',
    config = function()
      local pack_terminal = require("terminal");

      pack_terminal.setup({
        layout = { open_cmd = "botright new" },
      })
      local cmd = pack_terminal.terminal:new({
        autoclose = true,
        height=0.2
      })
      vim.keymap.set("n","<leader>t",
        function ()
          cmd:toggle(nil, true)
          cmd:send("echo hii")
        end
      )
    end
  }
}
