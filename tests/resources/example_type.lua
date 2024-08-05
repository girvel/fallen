local module_mt = {}
local example_type = setmetatable({}, module_mt)

example_type.mt = {
  __serialize = function(self)
    local a = self.a
    local b = self.b
    return function()
      local _type = require("tests.resources.example_type")
      return _type(a, b)
    end
  end,

  __eq = function(self, other)
    return self.a == other.a and self.b == other.b
  end,
}

module_mt.__call = function(_, a, b)
  return setmetatable({a = a, b = b}, example_type.mt)
end

return example_type
