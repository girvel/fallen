return function(variants)
  return Fun.iter(variants)
    :map(function(variant_name, argument_names)
      local unpack_arguments = function(instance)
        return unpack(Fun.iter(argument_names)
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

      local instance_mt = {__eq = function(self, other)
        return self.enum_variant == other.enum_variant and Fun.iter(argument_names)
          :all(function(k) return self[k] == other[k] end)
      end}

      return variant_name, setmetatable(result_variant, {
        __call = function(_, ...)
          local result = Fun.zip(argument_names, {...}):tomap()
          result.codename = variant_name
          result.enum_variant = result_variant
          result.unpack = unpack_arguments
          return setmetatable(result, instance_mt)
        end,
      })
    end)
    :tomap()
end
