local module_mt = {}
--- @overload fun(base_object: [number, number]): vector
local vector = setmetatable({}, module_mt)

--- @class vector
--- @field [1] number
--- @field [2] number
--- @operator add(vector): vector
--- @operator sub(vector): vector
--- @operator mul(number): vector
--- @operator div(number): vector
--- @operator unm(): vector
local vector_methods = {}
vector.mt = {__index = vector_methods}

module_mt.__call = function(_, base_object)
  assert(
    #base_object == 2 and Fun.iter(pairs(base_object)):length() == 2,
    "Vector base should be a list of length 2"
  )
  return setmetatable(base_object, vector.mt)
end

vector.zero = vector({0, 0})
vector.one = vector({1, 1})
vector.up = vector({0, -1})
vector.down = vector({0, 1})
vector.left = vector({-1, 0})
vector.right = vector({1, 0})

--- @alias direction_name "up" | "left" | "down" | "right"

vector.direction_names = {"up", "left", "down", "right"}
vector.directions = {vector.up, vector.left, vector.down, vector.right}
vector.extended_directions = {
  vector.up, vector.left, vector.down, vector.right,
  vector({1, 1}), vector({1, -1}), vector({-1, -1}), vector({-1, 1})
}

vector.name_from_direction = function(v)
  if v == vector.up then return "up" end
  if v == vector.down then return "down" end
  if v == vector.left then return "left" end
  if v == vector.right then return "right" end
end

--- @param f fun(n: number): number
--- @param ... vector
--- @return vector
vector.use = function(f, ...)
  local zip = Fun.zip(...)
  return vector({f(zip:nth(1)), f(zip:nth(2))})
end

vector.mt.__eq = function(self, other)
  return #other == 2 and self[1] == other[1] and self[2] == other[2]
end

vector.mt.__add = function(self, other)
  return vector({self[1] + other[1], self[2] + other[2]})
end

vector.mt.__sub = function(self, other)
  return vector({self[1] - other[1], self[2] - other[2]})
end

vector.mt.__mul = function(self, other)
  return vector({self[1] * other, self[2] * other})
end

vector.mt.__div = function(self, other)
  return vector({self[1] / other, self[2] / other})
end

vector.mt.__unm = function(self)
  return vector({-self[1], -self[2]})
end

vector.mt.__le = function(self, other)
  return self[1] <= other[1] and self[2] <= other[2]
end

vector.mt.__lt = function(self, other)
  return self[1] < other[1] and self[2] < other[2]
end

vector.mt.__ge = function(self, other)
  return other <= self
end

vector.mt.__gt = function(self, other)
  return other < self
end

vector.mt.__tostring = function(self)
  return "{" .. tostring(self[1]) .. "; " .. tostring(self[2]) .. "}"
end

vector.mt.__serialize = function(self)
  local x, y = unpack(self)
  return function()
    local _type = require("lib.types.vector")
    return _type({x, y})
  end
end

--- @param self vector
--- @return vector
vector_methods.ceil = function(self)
  return vector({math.ceil(self[1]), math.ceil(self[2])})
end

--- @param self vector
--- @param f fun(n: number): number
--- @return vector
vector_methods.map = function(self, f)
  return vector({f(self[1]), f(self[2])})
end

--- @param self vector
--- @return number
vector_methods.abs = function(self)
  return math.abs(self[1]) + math.abs(self[2])
end

--- @param self vector
--- @return vector
vector_methods.normalized = function(self)
  if math.abs(self[1]) > math.abs(self[2]) then
    return vector({Math.sign(self[1]), 0})
  elseif self[2] ~= 0 then
    return vector({0, Math.sign(self[2])})
  else
    error("Can not normalize Vector.zero")
  end
end

--- @param self vector
--- @return vector
vector_methods.fully_normalized = function(self)
  if self == Vector.zero then return Vector.zero end
  return self / self:abs()
end

return vector
