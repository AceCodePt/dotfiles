return {
  {
    -- Theme inspired by Atom
    'navarasu/onedark.nvim',
    priority = 1000,
    config = function()
      vim.cmd.colorscheme('onedark')

      -- Get the background color from the 'Normal' highlight group
      local normal_bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg

      -- Apply it to TabLineSel. This keeps the foreground but fixes the background.
      vim.api.nvim_set_hl(0, "TabLineSel", {
        bg = normal_bg,
      })
    end,
  },
  {
    'nvim-tree/nvim-web-devicons',
    config = function()
      -- Get a list of all highlight group names using the built-in getcompletion function
      local all_highlight_names = vim.fn.getcompletion("", "highlight")

      for _, name in ipairs(all_highlight_names) do
        -- Filter for devicon groups by checking the name prefix
        if string.sub(name, 1, 7) == "DevIcon" then
          local hl_id = vim.api.nvim_get_hl_id_by_name(name)

          -- Only proceed if the highlight group is valid
          if hl_id ~= 0 then
            -- Get the highlight definition using its ID
            local existing_hl = vim.api.nvim_get_hl(0, { id = hl_id })

            -- Set the highlight with a transparent background
            vim.api.nvim_set_hl(0, name, {
              fg = existing_hl.fg,
              ctermfg = existing_hl.ctermfg,
              bg = "NONE",      -- For GUIs
              ctermbg = "NONE", -- For Terminals
            })
          end
        end
      end
    end
  },

  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      options = {
        icons_enabled = true,
        theme = 'auto',
        component_separators = '|',
        section_separators = '',
      },
    },
  },
}
