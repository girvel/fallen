unpack = unpack or table.unpack
local fun = require("lib.fun")


return function(enum_name, variants)
  return fun.iter(variants)
    :map(function(variant_name, argument_names)
      local result_variant = {_variant_name = enum_name .. "." .. variant_name}
      result_variant.unpack = function(instance)
        if instance._enum_variant == result_variant._variant_name then
          return true, unpack(fun.iter(argument_names)
            :map(function(k) return instance[k] end)
            :totable())
        end
        return false
      end
      return variant_name, setmetatable(result_variant, {
        __call = function(self, ...)
          local result = fun.zip(argument_names, {...}):tomap()
          result._enum_variant = self._variant_name
          return result
        end,
      })
    end)
    :tomap()
end
