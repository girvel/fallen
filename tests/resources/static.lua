local module_mt = {}
local static = setmetatable({}, module_mt)

module_mt.__call = function(_, name, t)
  local source = debug.getinfo(2).source
  assert(source:sub(1, 1) == "@")
  t.__static_name = source:sub(2) .. "." .. name
  return setmetatable(t, static.__mt)
end

static.__mt = setmetatable({
  __eq = function(self, other)
    return self.__static_name == other.__static_name
  end,
}, {
  __serialize = function()
    return function()
      return require("tests.resources.static").__mt
    end
  end,
})

return static
