local module = {}
local module_mt = {}
setmetatable(module, module_mt)

local vector_methods = {}
local vector_mt = {__index = vector_methods}

module_mt.__call = function(_, base_object)
  assert(
    #base_object == 2 and Fun.iter(pairs(base_object)):length() == 2,
    "Vector base should be a list of length 2"
  )
  return setmetatable(base_object, vector_mt)
end

module.zero = module({0, 0})
module.one = module({1, 1})
module.up = module({0, -1})
module.down = module({0, 1})
module.left = module({-1, 0})
module.right = module({1, 0})

module.direction_names = {"up", "left", "down", "right"}
module.directions = {module.up, module.left, module.down, module.right}
module.extended_directions = {
  module.up, module.left, module.down, module.right,
  module({1, 1}), module({1, -1}), module({-1, -1}), module({-1, 1})
}

module.name_from_direction = function(v)
  if v == module.up then return "up" end
  if v == module.down then return "down" end
  if v == module.left then return "left" end
  if v == module.right then return "right" end
end

module.use = function(f, ...)
  local zip = Fun.zip(...)
  return module({f(zip:nth(1)), f(zip:nth(2))})
end

vector_mt.__eq = function(self, other)
  return #other == 2 and self[1] == other[1] and self[2] == other[2]
end

vector_mt.__add = function(self, other)
  return module({self[1] + other[1], self[2] + other[2]})
end

vector_mt.__sub = function(self, other)
  return module({self[1] - other[1], self[2] - other[2]})
end

vector_mt.__mul = function(self, other)
  return module({self[1] * other, self[2] * other})
end

vector_mt.__div = function(self, other)
  return module({self[1] / other, self[2] / other})
end

vector_mt.__unm = function(self)
  return module({-self[1], -self[2]})
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

vector_mt.__tostring = function(self)
  return "{" .. tostring(self[1]) .. "; " .. tostring(self[2]) .. "}"
end

vector_mt.__serialize = function(self)
  local x, y = unpack(self)
  return function()
    local _type = require("lib.types.vector")
    return _type({x, y})
  end
end

vector_methods.ceil = function(self)
  return module({math.ceil(self[1]), math.ceil(self[2])})
end

vector_methods.map = function(self, f)
  return module({f(self[1]), f(self[2])})
end

vector_methods.abs = function(self)
  return math.abs(self[1]) + math.abs(self[2])
end

vector_methods.normalized = function(self)
  if self[1] ~= 0 then return module({Math.sign(self[1]), 0}) end
  if self[2] ~= 0 then return module({0, Math.sign(self[2])}) end
  assert(false, "Can not normalize Vector.zero")
end

vector_methods.fully_normalized = function(self)
  if self == Vector.zero then return Vector.zero end
  return self / self:abs()
end

return module
