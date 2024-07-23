unpack = unpack or table.unpack
local fun = require("lib.fun")


return function(variants)
  return fun.iter(variants)
    :map(function(variant_name, argument_names)
      local unpack_arguments = function(instance)
        return unpack(fun.iter(argument_names)
          :map(function(k) return instance[k] end)
          :totable())
      end

      local result_variant = {}
      result_variant.unpack = function(instance)
        if instance.enum_variant == result_variant then
          return true, unpack_arguments(instance)
        end
        return false
      end
      return variant_name, setmetatable(result_variant, {
        __call = function(self, ...)
          local result = fun.zip(argument_names, {...}):tomap()
          result.enum_variant = self
          result.unpack = unpack_arguments
          return result
        end,
      })
    end)
    :tomap()
end
