local fun = require("lib.fun")
local module = require("lib.types.module")


local ordered_map, module_mt, static = module("lib.types.ordered_map")

local BASE_KEY = "_ordered_map__base"
ordered_map.is = function(self) return rawget(self, BASE_KEY) end

ordered_map.pairs = function(self)
  return setmetatable({index = 0}, {__call = function(iter, t, k)
    iter.index = iter.index + 1
    local pair = rawget(t, BASE_KEY)[iter.index]
    if pair then return unpack(pair) end
  end}), self
end

ordered_map.iter = function(self)
  return fun.iter(rawget(self, BASE_KEY))
    :map(function(pair) return unpack(pair) end)
end

module_mt.__call = function(_, base)
  return setmetatable({
    [BASE_KEY] = fun.pairs(base or {})
      :map(function(...) return {...} end)
      :totable(),
  }, {
    __index = function(self, k)
      local base = rawget(self, BASE_KEY)
      local pair = fun.iter(base)
        :filter(function(pair) return pair[1] == k end)
        :nth(1)
      return pair and pair[2]
    end,

    __newindex = function(self, k, v)
      local base = rawget(self, BASE_KEY)

      if v == nil then
        rawset(self, BASE_KEY, fun.iter(base)
          :filter(function(pair) return pair[1] ~= k end)
          :totable()
        )
        return
      end

      local pair = fun.iter(base)
        :filter(function(pair) return pair[1] == k end)
        :nth(1)

      if pair then
        pair[2] = v
        return
      end

      table.insert(base, {k, v})
    end,
  })
end

return ordered_map
