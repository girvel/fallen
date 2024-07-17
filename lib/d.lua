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
  return module.roll({{sides_n = sides_n, advantage = false}}, 0)
end

d_mt.__add = function(self, other)
  if type(other) == "number" then
    return module.roll(Tablex.deep_copy(self.dice), self.bonus + other)
  end

  if type(other) == "table" then
    return module.roll(
      Tablex.concat(Tablex.deep_copy(self.dice), other.dice),
      self.bonus + other.bonus
    )
  end

  error("Trying to add %s to a dice roll" % type(other))
end

d_mt.__mul = function(self, other)
  assert(type(other) == "number")
  return module.roll(
    Fun.iter(self.dice)
      :cycle()
      :take_n(#self.dice * other)
      :map(function(d) return Tablex.deep_copy(d) end)
      :totable(),
    self.bonus * other
  )
end

local roll_die = function(die)
  if die.advantage then
    return math.max(math.random(die.sides_n), math.random(die.sides_n))
  end
  return math.random(die.sides_n)
end

d_methods.roll = function(self)
  local rolls = Fun.iter(self.dice)
    :map(roll_die)
    :totable()
  local result = Fun.iter(rolls):sum() + self.bonus

  Log.debug(
    table.concat(
      Fun.zip(self.dice, rolls)
        :map(function(d, r) return r .. " (d" .. d.sides_n .. (d.advantage and ", Advantage" or "") .. ")" end)
        :totable(),
      " + "
    ) .. " + " .. self.bonus .. " = " .. result
  )

  return result
end

d_methods.max = function(self)
  return Fun.iter(self.dice)
    :map(function(d) return d.sides_n end)
    :sum() + self.bonus
end

d_methods.with_advantage = function(self, value)
  return module.roll(
    Fun.iter(self.dice)
      :map(function(x)
        return Tablex.extend(Tablex.deep_copy(x), {advantage = value})
      end)
      :totable(),
    self.bonus
  )
end

d_methods.to_string = function(self)
  return table.concat(
    Fun.iter(self.dice)
      :map(function(die) return "d" .. die.sides_n end)
      :totable(),
    " + "
  ) .. (self.bonus > 0 and (" + " .. self.bonus) or "")
end

return module
