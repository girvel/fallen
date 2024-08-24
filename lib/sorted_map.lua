return function(base)
  return setmetatable({
    base = Fun.pairs(base or {})
      :map(function(...) return {...} end)
      :totable(),
  }, {
    __index = function(self, k)
      local base = rawget(self, "base")
      local pair = Fun.iter(base)
        :filter(function(pair) return pair[1] == k end)
        :nth(1)
      return pair and pair[2]
    end,

    __newindex = function(self, k, v)
      local base = rawget(self, "base")

      if v == nil then
        rawset(self, "base", Fun.iter(base)
          :filter(function(pair) return pair[1] ~= k end)
          :totable()
        )
        return
      end

      local pair = Fun.iter(base)
        :map(function(pair) return pair[1] == k end)
        :nth(1)

      if pair then
        pair[2] = v
        return
      end

      table.insert(base, {k, v})
    end,

    __pairs = function(self)
      return Fun.iter(rawget(self, "base"))
        :map(function(pair) return unpack(pair) end)
    end,
  })
end
