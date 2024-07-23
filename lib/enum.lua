unpack = unpack or table.unpack
local fun = require("lib.fun")

local instance_mt = {__eq = function(self, other)
  for k, v in pairs(self) do
    if other[k] ~= v then return false end
  end
  for k, _ in pairs(other) do
    if not self[k] then return false end
  end
  return true
end}

return function(enum_name, variants)
  return fun.iter(variants)
    :map(function(variant_name, argument_names)
      local unpack_arguments = function(instance)
        return unpack(fun.iter(argument_names)
          :map(function(k) return instance[k] end)
          :totable())
      end

      local result_variant = {}
      result_variant.codename = enum_name .. "." .. variant_name
      result_variant.unpack = function(instance)
        if instance.enum_variant == result_variant then
          return true, unpack_arguments(instance)
        end
        return false
      end

      return variant_name, setmetatable(result_variant, {
        __call = function(_, ...)
          local result = fun.zip(argument_names, {...}):tomap()
          result.enum_variant = result_variant
          result.unpack = unpack_arguments
          return setmetatable(result, instance_mt)
        end,

        __eq = function(self, other)
          return self.codename == other.codename
        end,
      })
    end)
    :tomap()
end
