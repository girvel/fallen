local module, module_mt, static = Module("lib.types.d")

local d_methods = static {}
module.d_mt = static {__index = d_methods}

module.roll = function(dice, bonus)
  return setmetatable({
    dice = dice,
    bonus = bonus,
  }, module.d_mt)
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
      if Table.contains(self.reroll, result) then
        result = math.random(self.sides_n)
      end
      return result
    end,
  }, {
    __tostring = function(self)
      return "d%s%s%s" % {
        self.sides_n,
        self.advantage and "↑" or "",
        #self.reroll > 0 and ("🗘(%s)" % table.concat(self.reroll, ",")) or ""
      }
    end,
  })
end

module_mt.__call = function(_, sides_n)
  return module.roll({module.die(sides_n)}, 0)
end

module.d_mt.__add = function(self, other)
  if type(other) == "number" then
    return module.roll(Table.deep_copy(self.dice), self.bonus + other)
  end

  if type(other) == "table" then
    return module.roll(
      Table.concat(Table.deep_copy(self.dice), other.dice),
      self.bonus + other.bonus
    )
  end

  error("Trying to add %s to a dice roll" % type(other))
end

module.d_mt.__sub = function(self, other)
  if type(other) == "number" then
    return module.roll(Table.deep_copy(self.dice), self.bonus - other)
  end

  error("Trying to subtract %s to a dice roll" % type(other))
end

module.d_mt.__mul = function(self, other)
  assert(type(other) == "number")
  return module.roll(
    Fun.iter(self.dice)
      :cycle()
      :take_n(#self.dice * other)
      :map(function(d) return Table.deep_copy(d) end)
      :totable(),
    self.bonus * other
  )
end

module.d_mt.__tostring = function(self)
  local dice = table.concat(
    Fun.iter(self.dice)
      :map(tostring)
      :totable(),
    " + "
  )
  local bonus = self.bonus > 0 and tostring(self.bonus) or ""
  local plus = #dice > 0 and #bonus > 0 and " + " or ""
  return dice .. plus .. bonus
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
          return "%s (%s)" % {r, tostring(d)}
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

d_methods.min = function(self)
  return #self.dice + self.bonus
end

d_methods.extended = function(self, modification)
  return module.roll(
    Fun.iter(self.dice)
      :map(function(x)
        return Table.extend(Table.deep_copy(x), modification)
      end)
      :totable(),
    self.bonus
  )
end

return module
