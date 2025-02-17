local tablex = require("lib.table")


local module_mt = {}
local fn = setmetatable({}, module_mt)

module_mt.__call = function(_, ...)
  local args = {...}
  return function() return unpack(args) end
end

fn.identity = function(...) return ... end

--- @param f function
--- @return function
fn.curry = function(f, ...)
  local curried_args = {...}
  return function(...)
    return f(unpack(tablex.concat({}, curried_args, {...})))
  end
end

return fn
