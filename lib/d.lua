local common = require("utils.common")


local module = {}
local module_mt = {}
setmetatable(module, module_mt)

local d_methods = {}
local d_mt = {__index = d_methods}

module.roll = function(dice, bonus)
  return setmetatable({
    dice = dice,
    bonus = bonus,
  }, d_mt)
end

module_mt.__call = function(_, sides_n)
  return module.roll({sides_n}, 0)
end

d_mt.__add = function(self, other)
  if type(other) == "number" then
    return module.roll({unpack(self.dice)}, self.bonus + other)
  end

  if type(other) == "table" then
    return module.roll(common.concat({unpack(self.dice)}, other.dice), self.bonus + other.bonus)
  end

  assert(false)
end

d_mt.__mul = function(self, other)
  assert(type(other) == "number")
  return module.roll(
    Fun.iter(self.dice)
      :cycle()
      :take_n(#self.dice * other)
      :totable(),
    self.bonus * other
  )
end

d_methods.roll = function(self)
  return Fun.iter(self.dice)
    :map(function(sides) return math.random(sides) end)
    :sum() + self.bonus
end

return module
