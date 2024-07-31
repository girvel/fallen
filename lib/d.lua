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

module.die = function(sides_n)
  return setmetatable({
    sides_n = sides_n,
    advantage = false,
    reroll = {},
    roll = function(self)
      local result = math.random(self.sides_n)
      if self.advantage then
        result = math.max(result, math.random(self.sides_n))
      end
      if Tablex.contains(self.reroll, result) then
        result = math.random(self.sides_n)
      end
      return result
    end,
  }, {
    __repr = function(self)
      return "d%s%s%s" % {
        self.sides_n,
        self.advantage and ", advantage" or "",
        #self.reroll > 0 and (", reroll " .. table.concat(self.reroll, ", ")) or ""
      }
    end,
  })
end

module_mt.__call = function(_, sides_n)
  return module.roll({module.die(sides_n)}, 0)
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

d_mt.__sub = function(self, other)
  if type(other) == "number" then
    return module.roll(Tablex.deep_copy(self.dice), self.bonus - other)
  end

  error("Trying to subtract %s to a dice roll" % type(other))
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

d_methods.roll = function(self)
  local rolls = Fun.iter(self.dice)
    :map(function(d) return d:roll() end)
    :totable()
  local result = Fun.iter(rolls):sum() + self.bonus

  Log.debug(
    table.concat(
      Fun.zip(self.dice, rolls)
        :map(function(d, r)
          return "%s (%s)" % {r, Common.repr(d)}
        end)
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

d_methods.extended = function(self, modification)
  return module.roll(
    Fun.iter(self.dice)
      :map(function(x)
        return Tablex.extend(Tablex.deep_copy(x), modification)
      end)
      :totable(),
    self.bonus
  )
end

d_methods.to_string = function(self)
  return table.concat(
    Fun.iter(self.dice)
      :map(tostring)
      :totable(),
    " + "
  ) .. (self.bonus > 0 and (" + " .. self.bonus) or "")
end

return module
