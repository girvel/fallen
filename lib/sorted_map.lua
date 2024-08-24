return function(base_array)
  return setmetatable({
    base_array = Fun.pairs(base_array or {})
      :map(function(...) return {...} end)
      :totable(),
  }, {
    __index = function(self, k)
      local base = rawget(self, "base_array")
      if k == "iter" then
        return function()
          return Fun.iter(base)
            :map(function(pair) return unpack(pair) end)
        end
      end
      return Fun.iter(base)
        :filter(function(pair) return pair[1] == k end)
        :nth(1)[2]
    end,

    __newindex = function(self, k, v)
      local base = rawget(self, "base_array")

      if v == nil then
        rawset(self, "base_array", Fun.iter(base)
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
  })
end
