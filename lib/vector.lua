local fun = require("lib/fun")


local module = {}
local module_mt = {}
setmetatable(module, module_mt)

local vector_mt = {}

module_mt.__call = function(_, base_object)
  assert(#base_object == 2 and fun.iter(pairs(base_object)):length() == 2)
  return setmetatable(base_object, vector_mt)
end

vector_mt.__add = function(self, other)
  return module({self[1] + other[1], self[2] + other[2]})
end

vector_mt.__mul = function(self, other)
  return module({self[1] * other, self[2] * other})
end

return module
