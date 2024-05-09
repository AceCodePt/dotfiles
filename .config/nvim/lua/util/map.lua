local M = {}

function M.map(mode, lhs, rhs, opts)
   local _opts = opts or {}
   -- set default value if not specify
   if _opts.noremap == nil then
     _opts.noremap = true
   end
   if _opts.silent == nil then
     _opts.silent = true
   end

   vim.keymap.set(mode, lhs, rhs, _opts)
end

return  M
