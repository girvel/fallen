-- local collider = {}
-- 
-- local static = function(name, t)
--   local source = debug.getinfo(2).source
--   assert(source:sub(1, 1) == "@")
--   t.__static_name = source:sub(2) .. "." .. name
--   return setmetatable(t, {
--     __eq = function(self, other)
--       return self.static
--     end,
--   })
-- end

return {}
