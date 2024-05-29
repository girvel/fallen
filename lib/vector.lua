local fun = require("lib/fun")


local module = {}
local module_mt = {}
setmetatable(module, module_mt)

local vector_mt = {}

module_mt.__call = function(_, base_object)
  assert(#base_object == 2 and fun.iter(pairs(base_object)):length() == 2)
  return setmetatable(base_object, vector_mt)
end

module.zero = function() return module({0, 0}) end

vector_mt.__add = function(self, other)
  return module({self[1] + other[1], self[2] + other[2]})
end

vector_mt.__mul = function(self, other)
  return module({self[1] * other, self[2] * other})
end

vector_mt.__le = function(self, other)
  return self[1] <= other[1] and self[2] <= other[2]
end

vector_mt.__lt = function(self, other)
  return self[1] < other[1] and self[2] < other[2]
end

vector_mt.__ge = function(self, other)
  return other <= self
end

vector_mt.__gt = function(self, other)
  return other < self
end

return module
