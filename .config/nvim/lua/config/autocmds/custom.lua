local convert_selection_to_camel = require("util.camel_case").convert_selection_to_camel


-- Create a user command that can be called on a range.
-- Usage: Select text, then type: :CamelCase
vim.api.nvim_create_user_command("CamelCase", convert_selection_to_camel, {
  range = true,
  desc = "Convert selected text to camelCase",
})
